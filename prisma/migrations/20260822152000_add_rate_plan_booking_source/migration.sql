SET @col_exists := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'rate_plans'
    AND COLUMN_NAME = 'booking_source'
);

SET @col_sql := IF(
  @col_exists = 0,
  'ALTER TABLE `rate_plans` ADD COLUMN `booking_source` ENUM(''direct'',''travel_agent'',''walk_in'',''online'') NULL',
  'SELECT 1'
);

PREPARE col_stmt FROM @col_sql;
EXECUTE col_stmt;
DEALLOCATE PREPARE col_stmt;

SET @old_idx_exists := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'rate_plans'
    AND INDEX_NAME = 'rate_plans_room_type_id_travel_agent_id_meal_plan_id_key'
);

SET @drop_sql := IF(
  @old_idx_exists > 0,
  'ALTER TABLE `rate_plans` DROP INDEX `rate_plans_room_type_id_travel_agent_id_meal_plan_id_key`',
  'SELECT 1'
);

PREPARE drop_stmt FROM @drop_sql;
EXECUTE drop_stmt;
DEALLOCATE PREPARE drop_stmt;

SET @new_idx_exists := (
  SELECT COUNT(*)
  FROM INFORMATION_SCHEMA.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE()
    AND TABLE_NAME = 'rate_plans'
    AND INDEX_NAME = 'RatePlan_roomTypeId_travelAgentId_mealPlanId_bookingSource_key'
);

SET @add_sql := IF(
  @new_idx_exists = 0,
  'ALTER TABLE `rate_plans` ADD UNIQUE INDEX `RatePlan_roomTypeId_travelAgentId_mealPlanId_bookingSource_key` (`room_type_id`, `travel_agent_id`, `meal_plan_id`, `booking_source`)',
  'SELECT 1'
);

PREPARE add_stmt FROM @add_sql;
EXECUTE add_stmt;
DEALLOCATE PREPARE add_stmt;
