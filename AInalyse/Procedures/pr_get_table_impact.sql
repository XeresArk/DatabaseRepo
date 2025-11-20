DROP PROCEDURE PR_GET_TABLE_IMPACT;

DELIMITER $$

CREATE PROCEDURE PR_GET_TABLE_IMPACT(
    IN P_OWNER VARCHAR(64),
    IN P_TABLE_NAME VARCHAR(64),
    IN P_COLUMN_NAME VARCHAR(64)

)
BEGIN
	DECLARE V_OWNER VARCHAR(64);
    DECLARE V_TABLE_NAME VARCHAR(64);
    DECLARE V_COLUMN_NAME VARCHAR(64);
    DECLARE V_RUN_ID INT;
	
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Unhandled exception inside PR_GET_TABLE_IMPACT';
    END;

    -- Convert to upper case for consistent search
    SET V_OWNER = UPPER(P_OWNER);
    SET V_TABLE_NAME = UPPER(P_TABLE_NAME);
    SET V_COLUMN_NAME = UPPER(P_COLUMN_NAME);

	START TRANSACTION;

    -- Get run ID
    SELECT COALESCE(MAX(RUN_ID), 0) + 1
    INTO V_RUN_ID
    FROM HACKATHON_SEARCH_RESULT;

    -- TABLE IMPACT CHECKS
    IF V_TABLE_NAME IS NOT NULL AND V_COLUMN_NAME IS NULL THEN

        -- 1) VIEWS referencing this table
        INSERT INTO HACKATHON_SEARCH_RESULT
        (run_id, search_desc, owner_name, table_name, created_by, created_date)
        SELECT 
            V_RUN_ID,
            UPPER(view_name),
            V_OWNER,
            V_TABLE_NAME,
            'SYSTEM',
            CURRENT_TIMESTAMP
        FROM information_schema.view_table_usage
        WHERE table_schema = V_OWNER
          AND table_name = V_TABLE_NAME;


        -- 2) PROCEDURES & FUNCTIONS referencing this table
        INSERT INTO HACKATHON_SEARCH_RESULT
        (run_id, search_desc, owner_name, table_name, created_by, created_date)
        SELECT
            V_RUN_ID,
            UPPER(CONCAT(routine_name, ' ', routine_type)),
            V_OWNER,
            V_TABLE_NAME,
            'SYSTEM',
            CURRENT_TIMESTAMP
        FROM information_schema.routines
        WHERE routine_schema = V_OWNER
          AND routine_definition LIKE CONCAT('%', V_TABLE_NAME, '%');


        -- 3) FOREIGN KEY CONSTRAINTS involving this table
        INSERT INTO HACKATHON_SEARCH_RESULT
        (run_id, search_desc, owner_name, table_name, created_by, created_date)
        SELECT
            V_RUN_ID,
            UPPER(CONCAT(V_TABLE_NAME, ' ', constraint_name, ' ', referenced_table_name)),
            V_OWNER,
            V_TABLE_NAME,
            'SYSTEM',
            CURRENT_TIMESTAMP
        FROM information_schema.referential_constraints
        WHERE constraint_schema = V_OWNER
          AND table_name = V_TABLE_NAME;

    END IF;

    -- COLUMN IMPACT CHECKS
    IF V_TABLE_NAME IS NOT NULL AND V_COLUMN_NAME IS NOT NULL THEN

        -- 1) TABLES containing the column
        INSERT INTO HACKATHON_SEARCH_RESULT
        (run_id, search_desc, owner_name, table_name, column_name, created_by, created_date)
        SELECT
            V_RUN_ID,
            UPPER(CONCAT(TABLE_NAME, '.', COLUMN_NAME)),
            V_OWNER,
            UPPER(TABLE_NAME),
            UPPER(COLUMN_NAME),
            'SYSTEM',
            CURRENT_TIMESTAMP
        FROM information_schema.columns
        WHERE table_schema = V_OWNER
          AND column_name = V_COLUMN_NAME;

        -- 3) PROCEDURES & FUNCTIONS referencing the column
        INSERT INTO HACKATHON_SEARCH_RESULT
        (run_id, search_desc, owner_name, table_name, column_name, created_by, created_date)
        SELECT
            V_RUN_ID,
            UPPER(CONCAT(routine_type, ' ', routine_name)),
            V_OWNER,
            V_TABLE_NAME,
            V_COLUMN_NAME,
            'SYSTEM',
            CURRENT_TIMESTAMP
        FROM information_schema.routines
        WHERE routine_schema = V_OWNER
          AND routine_definition LIKE CONCAT('%', V_COLUMN_NAME, '%');


        -- 4) TRIGGERS referencing the column
        INSERT INTO HACKATHON_SEARCH_RESULT
        (run_id, search_desc, owner_name, table_name, column_name, created_by, created_date)
        SELECT
            V_RUN_ID,
            UPPER(trigger_name),
            V_OWNER,
            V_TABLE_NAME,
            V_COLUMN_NAME,
            'SYSTEM',
            CURRENT_TIMESTAMP
        FROM information_schema.triggers
        WHERE trigger_schema = V_OWNER
          AND action_statement LIKE CONCAT('%', V_COLUMN_NAME, '%');

    END IF;

    COMMIT;
	
END$$

DELIMITER ;