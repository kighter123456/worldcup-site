-- ============================================================================
-- 数据库完整性自检脚本(第 2 版,对应 install.sql 第 2 版)
-- 用法:mysql -u root -p < data/check.sql      (或 mysql -u root -p worldcup < data/check.sql)
-- 目的:确认 install.sql 导入后表结构完整(表数量 / 外键 / 唯一索引 / 基础数据 / 中文)
-- ============================================================================

USE `worldcup`;

SELECT '=== 0. 版本与库 ===' AS section;
SELECT VERSION() AS mysql_version, DATABASE() AS db_name, @@character_set_database AS db_charset,
       @@collation_database AS db_collation;

SELECT '=== 1. 表清单(应为 14 张,引擎 InnoDB,排序规则 utf8mb4_unicode_ci) ===' AS section;
SELECT TABLE_NAME, ENGINE, TABLE_COLLATION
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME;

SELECT '=== 2. 表数量(应为 14) ===' AS section;
SELECT COUNT(*) AS table_count
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_TYPE = 'BASE TABLE';

SELECT '=== 3. 外键清单(应为 16 条) ===' AS section;
SELECT TABLE_NAME, CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME, REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE() AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;

SELECT '=== 4. 外键数量(应为 16) ===' AS section;
SELECT COUNT(DISTINCT CONSTRAINT_NAME) AS fk_count
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE() AND REFERENCED_TABLE_NAME IS NOT NULL;

SELECT '=== 5. 唯一索引(应为 9 个:uk_year / uk_name / uk_code / uk_username / uk_tournament_team / uk_squad_player / uk_squad_shirt / uk_comment_user / uk_student_id) ===' AS section;
SELECT DISTINCT TABLE_NAME, INDEX_NAME
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE() AND NON_UNIQUE = 0 AND INDEX_NAME <> 'PRIMARY'
ORDER BY TABLE_NAME, INDEX_NAME;

SELECT '=== 6. 每张表的索引数(应 >= 1,即至少有主键) ===' AS section;
SELECT TABLE_NAME, COUNT(DISTINCT INDEX_NAME) AS index_count
FROM information_schema.STATISTICS
WHERE TABLE_SCHEMA = DATABASE()
GROUP BY TABLE_NAME
ORDER BY TABLE_NAME;

SELECT '=== 7. 基础数据行数(顺序应为 11 / 2 / 1 / 4) ===' AS section;
SELECT 'tournament 届次' AS item, COUNT(*) AS row_count FROM `tournament`
UNION ALL SELECT 'user 用户',        COUNT(*) FROM `user`
UNION ALL SELECT 'team_info 团队',   COUNT(*) FROM `team_info`
UNION ALL SELECT 'member 成员',      COUNT(*) FROM `member`;

SELECT '=== 8. 届次的积分规则(1986/1990 应为 2,其余应为 3) ===' AS section;
SELECT `year`, `win_points`, `format` FROM `tournament` ORDER BY `year`;

SELECT '=== 9. 中文完整性(不应出现 ??? 或乱码) ===' AS section;
SELECT name, slogan FROM `team_info`;
SELECT name, duty FROM `member`;

SELECT '=== 10. 关键约束抽查(game 表应能看到 3 个外键) ===' AS section;
SELECT CONSTRAINT_NAME, COLUMN_NAME, REFERENCED_TABLE_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'game' AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY CONSTRAINT_NAME;

SELECT '=== 11. CHECK 约束清单(应能看到 chk_ 开头的多条) ===' AS section;
SELECT CONSTRAINT_NAME, CHECK_CLAUSE
FROM information_schema.CHECK_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = DATABASE()
ORDER BY CONSTRAINT_NAME;

SELECT '=== 12. 残留检查(不应再存在 match 表) ===' AS section;
SELECT COUNT(*) AS leftover_match_table
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'match';

SELECT '=== 自检结束 ===' AS section;
