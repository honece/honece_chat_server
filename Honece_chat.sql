/*
 Navicat MySQL Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80027 (8.0.27)
 Source Host           : localhost:3306
 Source Schema         : honece_chat

 Target Server Type    : MySQL
 Target Server Version : 80027 (8.0.27)
 File Encoding         : 65001

 Date: 26/03/2023 13:27:46
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for chat_friend
-- ----------------------------
DROP TABLE IF EXISTS `chat_friend`;
CREATE TABLE `chat_friend`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `member_id` int UNSIGNED NOT NULL COMMENT '账号id',
  `friend_id` int NOT NULL COMMENT '好友id',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT NULL,
  `delete_time` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '会员分组下的好友列表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for chat_group
-- ----------------------------
DROP TABLE IF EXISTS `chat_group`;
CREATE TABLE `chat_group`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `group_name` varchar(60) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '群名称',
  `member_id` int UNSIGNED NOT NULL COMMENT '群主',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT NULL,
  `delete_time` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `group_name`(`group_name` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '聊天群表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for chat_group_member
-- ----------------------------
DROP TABLE IF EXISTS `chat_group_member`;
CREATE TABLE `chat_group_member`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `group_id` int UNSIGNED NOT NULL COMMENT '群ID',
  `member_id` int UNSIGNED NOT NULL COMMENT '用户ID',
  `type` tinyint UNSIGNED NOT NULL DEFAULT 1 COMMENT '0群主 1会员',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NULL DEFAULT NULL,
  `delete_time` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '群员表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for chat_member
-- ----------------------------
DROP TABLE IF EXISTS `chat_member`;
CREATE TABLE `chat_member`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `account` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '账号',
  `status` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '在线状态 0在线 1下线 2隐身',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` datetime NULL DEFAULT NULL COMMENT '登陆时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '会员表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for chat_msgbox
-- ----------------------------
DROP TABLE IF EXISTS `chat_msgbox`;
CREATE TABLE `chat_msgbox`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `send` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '消息发送者',
  `recv` int UNSIGNED NOT NULL COMMENT '消息接收者',
  `type` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '0加好友 1系统消息(加好友) 2请求加群 3系统消息(加群)',
  `status` tinyint UNSIGNED NOT NULL DEFAULT 0 COMMENT '0待处理 1同意 2拒绝',
  `group_id` int NOT NULL DEFAULT 0 COMMENT '群ID',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_time` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更改时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `send&recv&group_id`(`send` ASC, `recv` ASC, `group_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '通知表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Table structure for chat_record
-- ----------------------------
DROP TABLE IF EXISTS `chat_record`;
CREATE TABLE `chat_record`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `sender` int UNSIGNED NOT NULL COMMENT '发送者',
  `receiver` int UNSIGNED NOT NULL COMMENT '接收者',
  `content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL COMMENT '发送内容',
  `type` enum('friend','group') CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL DEFAULT 'friend' COMMENT '聊天类型',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NOT NULL,
  `delete_time` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `send`(`sender` ASC) USING BTREE,
  INDEX `receive`(`receiver` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '聊天记录表' ROW_FORMAT = DYNAMIC;

SET FOREIGN_KEY_CHECKS = 1;
