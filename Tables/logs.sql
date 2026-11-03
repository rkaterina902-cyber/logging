DECLARE
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count FROM user_tables WHERE table_name='LOGS';
  IF v_count = 0 THEN
    EXECUTE IMMEDIATE 'CREATE TABLE logs (appl_proc VARCHAR2(100), message VARCHAR2(4000), log_date DATE)';
  END IF;
END;
/
