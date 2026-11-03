-- SQLcl / SQL*Plus: встановлення з підключенням до цільової схеми.
-- Перевірте залежності та права перед запуском.

DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM user_tables WHERE table_name='LOGS';
  IF v_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLE logs (appl_proc VARCHAR2(100), message VARCHAR2(4000), log_date DATE)';
  END IF;
END;
/

CREATE OR REPLACE PACKAGE log_utils AS

    PROCEDURE log_start(
        p_proc_name IN VARCHAR2,
        p_text      IN VARCHAR2 DEFAULT NULL
    );

    PROCEDURE log_finish(
        p_proc_name IN VARCHAR2,
        p_text      IN VARCHAR2 DEFAULT NULL
    );

    PROCEDURE log_error(
        p_proc_name IN VARCHAR2,
        p_sqlerrm   IN VARCHAR2,
        p_text      IN VARCHAR2 DEFAULT NULL
    );

END log_utils;
/

CREATE OR REPLACE PACKAGE BODY log_utils AS

    -- Приватна процедура.
    -- Вона НЕ оголошена в PACKAGE specification.
    PROCEDURE to_log(
        p_appl_proc IN VARCHAR2,
        p_message   IN VARCHAR2
    ) IS
    BEGIN
        INSERT INTO logs (
            appl_proc,
            message,
            log_date
        )
        VALUES (
            p_appl_proc,
            p_message,
            SYSDATE
        );

        COMMIT;
    END to_log;


    -- =========================================================
    -- LOG_START
    -- =========================================================
    PROCEDURE log_start(
        p_proc_name IN VARCHAR2,
        p_text      IN VARCHAR2 DEFAULT NULL
    ) IS
        v_text VARCHAR2(4000);
    BEGIN

        IF p_text IS NULL THEN
            v_text := 'Старт логування, назва процесу = ' || p_proc_name;
        ELSE
            v_text := p_text;
        END IF;

        to_log(
            p_appl_proc => p_proc_name,
            p_message   => v_text
        );

    END log_start;


    -- =========================================================
    -- LOG_FINISH
    -- =========================================================
    PROCEDURE log_finish(
        p_proc_name IN VARCHAR2,
        p_text      IN VARCHAR2 DEFAULT NULL
    ) IS
        v_text VARCHAR2(4000);
    BEGIN

        IF p_text IS NULL THEN
            v_text := 'Завершення логування, назва процесу = ' || p_proc_name;
        ELSE
            v_text := p_text;
        END IF;

        to_log(
            p_appl_proc => p_proc_name,
            p_message   => v_text
        );

    END log_finish;


    -- =========================================================
    -- LOG_ERROR
    -- =========================================================
    PROCEDURE log_error(
        p_proc_name IN VARCHAR2,
        p_sqlerrm   IN VARCHAR2,
        p_text      IN VARCHAR2 DEFAULT NULL
    ) IS
        v_text VARCHAR2(4000);
    BEGIN

        IF p_text IS NULL THEN
            v_text := 'В процедурі ' ||
                      p_proc_name ||
                      ' сталася помилка. ' ||
                      p_sqlerrm;
        ELSE
            v_text := p_text;
        END IF;

        to_log(
            p_appl_proc => p_proc_name,
            p_message   => v_text
        );

    END log_error;

END log_utils;
/
