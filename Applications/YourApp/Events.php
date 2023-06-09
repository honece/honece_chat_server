<?php
/**
 * This file is part of workerman.
 *
 * Licensed under The MIT License
 * For full copyright and license information, please see the MIT-LICENSE.txt
 * Redistributions of files must retain the above copyright notice.
 *
 * @author walkor<walkor@workerman.net>
 * @copyright walkor<walkor@workerman.net>
 * @link http://www.workerman.net/
 * @license http://www.opensource.org/licenses/mit-license.php MIT License
 */

/**
 * 用于检测业务代码死循环或者长时间阻塞等问题
 * 如果发现业务卡死，可以将下面declare打开（去掉//注释），并执行php start.php reload
 * 然后观察一段时间workerman.log看是否有process_timeout异常
 */
//declare(ticks=1);

use \GatewayWorker\Lib\Gateway;
use Workerman\MySQL\Connection;

/**
 * 主逻辑
 * 主要是处理 onConnect onMessage onClose 三个方法
 * onConnect 和 onClose 如果不需要可以不用实现并删除
 */
class Events
{
    /**
     * 新建一个类的静态成员，用来保存数据库实例
     */
    public static $db = null;

    /**
     * 进程启动后初始化数据库连接
     */
    public static function onWorkerStart($worker)
    {
        self::$db = new Connection('127.0.0.1', '3306', 'root', 'root', 'honece_chat');
    }
    /**
     * 当客户端连接时触发
     * 如果业务不需此回调可以删除onConnect
     * 
     * @param int $client_id 连接id
     */
    public static function onConnect($client_id)
    {
        // 向当前client_id发送数据 
        Gateway::sendToClient($client_id, "Hello $client_id\r\n");
        // 向所有人发送
        Gateway::sendToAll("$client_id login\r\n");

    }

    /**
     * 当客户端发来消息时触发
     * @param int $client_id 连接id
     * @param mixed $message 具体消息
     */
    public static function onMessage($client_id, $message)
    {
        $data = json_decode($message, true);

        // Gateway::sendToAll("{$message}\r\n");
        //绑定客户端id
        switch ($data['action']) {
            case 'login':
                //登录初始化
                //客户端绑定群
                $addmsg = self::$db->select('group_id')
                    ->from('chat_group_member')
                    ->where('member_id = ' . $data['user']['id'])
                    ->column();
                if ($addmsg) {
                    foreach ($addmsg as $key => $groupId) {
                        Gateway::joinGroup($client_id, $groupId);
                    }
                }
                //将客户端id绑定uid
                $_SESSION['UID'] = $data['user']['id'];
                Gateway::bindUid($client_id, $data['user']['id']);

                //查询是否有申请信息
                $addmsg = self::$db->select('type')
                    ->from('chat_msgbox')
                    ->where('recv = ' . $data['user']['id'])
                    ->where('status = 0')
                    ->column();
                if ($addmsg) {
                    Gateway::sendToUid(
                        $data['user']['id'],
                        "您的申请列表中有未读信息，请去申请信息菜单中查看\r\n"
                    );
                }
                //更改在线状态
                self::$db->update('chat_member')->cols(['status' => '0'])->where('id=' . $data['user']['id'])->query();

                // 向所有人发送 ，可以只对在线好友发送,功能未实现
                Gateway::sendToAll("{$data['user']['name']} 已经上线\r\n");
                break;
            case 'addfriend':
                //添加申请好友消息
                $insert_id = self::$db->insert('chat_msgbox')->cols(
                    [
                        'send' => $data['user']['id'],
                        'recv' => $data['data']['friend_id']
                    ]
                )->query();

                if (Gateway::isUidOnline($data['data']['friend_id'])) {
                    Gateway::sendToUid(
                        $data['data']['friend_id'],
                        $data['user']['name'] . "申请加您为好友，请去申请信息菜单中查看\r\n"
                    );
                }
                break;
            case 'addGroup':
                //添加申请入群消息
                $insert_id = self::$db->insert('chat_msgbox')->cols(
                    [
                        'send'     => $data['user']['id'],
                        'recv'     => $data['data']['recv_id'],
                        'type'     => '2',
                        'group_id' => $data['data']['group_id']
                    ]
                )->query();

                if (Gateway::isUidOnline($data['data']['recv_id'])) {
                    Gateway::sendToUid(
                        $data['data']['recv_id'],
                        $data['user']['name'] . "申请加群，请去申请信息菜单中查看\r\n"
                    );
                }
                break;
            case 'chat':
                //好友聊天
                Gateway::sendToUid(
                    $data['data']['friend_id'],
                    "收到新的好友消息\r\n" .
                    'user:' . $data['user']['name'] . "\t" .
                    date('Y-m-d H:i:s') . "\t" .
                    $data['data']['msg'] . "\r\n"
                );
                break;
            case 'chatGroup':
                Gateway::sendToGroup(
                    $data['data']['group_id'],
                    //消息大概是 :
                    // xxx:     2023-03-20 00:00:00
                    //   消息内容
                    //这种格式
                    "收到新的群消息\r\n" .
                    $data['user']['name'] . ":\t" . date('Y-m-d H:i:s') . "\r\n\t" .
                    $data['data']['msg'] . "\r\n"
                );
                break;
            case 'joinGroup':
                //绑定uid进组
                $clientIds = Gateway::getClientIdByUid($data['data']['member_id']);
                foreach ($clientIds as $key => $value) {
                    Gateway::joinGroup($value, $data['data']['group_id']);
                }
                if ($data['data']['member_id'] != $data['user']['id']) {
                    Gateway::sendToUid($data['data']['member_id'], "您的群组申请已通过\r\n");
                }
                break;
        }

    }

    /**
     * 当用户断开连接时触发
     * @param int $client_id 连接id
     */
    public static function onClose($client_id)
    {
        //成员下线
        $uidList = Gateway::getClientIdByUid($_SESSION['UID']);
        if (empty($uidList) && !empty($_SESSION['UID'])) {
            self::$db->update('chat_member')->cols(['status' => '1'])->where('id=' . $_SESSION['UID'])->query();
        }
        // 向所有人发送 
        GateWay::sendToAll("$client_id logout\r\n");
    }
}