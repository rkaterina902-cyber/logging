-- SQLcl / SQL*Plus: SET SERVEROUTPUT ON, then run this file.
DECLARE
  v_name VARCHAR2(100) := 'SQL_TEST_' || SUBSTR(RAWTOHEX(SYS_GUID()), 1, 12);
  v_count NUMBER;
BEGIN
  -- Цей рядок належить транзакції викликача й має зникнути після ROLLBACK.
  INSERT INTO logs(appl_proc, message, log_date)
  VALUES(v_name, 'CALLER_UNCOMMITTED', SYSDATE);
  log_utils.log_start(v_name);
  log_utils.log_finish(v_name, 'Тестове завершення');
  log_utils.log_error(v_name, 'ORA-20000', 'Тестова помилка');
  ROLLBACK;
  SELECT COUNT(*) INTO v_count FROM logs
   WHERE appl_proc = v_name AND message = 'CALLER_UNCOMMITTED';
  IF v_count <> 0 THEN
    raise_application_error(-20989, 'TO_LOG зафіксувала транзакцію викликача');
  END IF;
  SELECT COUNT(*) INTO v_count FROM logs WHERE appl_proc = v_name;
  IF v_count <> 3 THEN
    raise_application_error(-20990, 'Очікувалось 3 записи LOGS, знайдено ' || v_count);
  END IF;
  SELECT COUNT(*) INTO v_count FROM user_procedures
   WHERE object_name = 'LOG_UTILS' AND procedure_name = 'TO_LOG';
  IF v_count <> 0 THEN
    raise_application_error(-20991, 'TO_LOG не має бути публічною');
  END IF;
  DBMS_OUTPUT.PUT_LINE('PASS: LOG_UTILS, автономна транзакція');
END;
/
