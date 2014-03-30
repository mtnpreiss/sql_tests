SET SERVEROUTPUT ON
SET VERIFY OFF

create or replace procedure get_space_usage(p_segment_name varchar2 default 'T_IDX', p_segment_type varchar2 default 'INDEX')
as
  v_unformatted_blocks              NUMBER;
  v_unformatted_bytes               NUMBER;
  v_fs1_blocks                      NUMBER;
  v_fs1_bytes                       NUMBER;
  v_fs2_blocks                      NUMBER;
  v_fs2_bytes                       NUMBER;
  v_fs3_blocks                      NUMBER;
  v_fs3_bytes                       NUMBER;
  v_fs4_blocks                      NUMBER;
  v_fs4_bytes                       NUMBER;
  v_full_blocks                     NUMBER;
  v_full_bytes                      NUMBER;

BEGIN
    DBMS_SPACE.SPACE_USAGE  (segment_owner              => user, 
                             segment_name               => p_segment_name,
                             segment_type               => p_segment_type,
                             unformatted_blocks         => v_unformatted_blocks,
                             unformatted_bytes          => v_unformatted_bytes,
                             fs1_blocks                 => v_fs1_blocks,
                             fs1_bytes                  => v_fs1_bytes,
                             fs2_blocks                 => v_fs2_blocks,
                             fs2_bytes                  => v_fs2_bytes,
                             fs3_blocks                 => v_fs3_blocks,
                             fs3_bytes                  => v_fs3_bytes,
                             fs4_blocks                 => v_fs4_blocks,
                             fs4_bytes                  => v_fs4_bytes,
                             full_blocks                => v_full_blocks,
                             full_bytes                 => v_full_bytes
                             );

  DBMS_OUTPUT.PUT_LINE('unformatted_blocks                :' || v_unformatted_blocks);
  DBMS_OUTPUT.PUT_LINE('unformatted_bytes                 :' || v_unformatted_bytes);
  DBMS_OUTPUT.PUT_LINE('fs1_blocks                        :' || v_fs1_blocks);
  DBMS_OUTPUT.PUT_LINE('fs1_bytes                         :' || v_fs1_bytes);
  DBMS_OUTPUT.PUT_LINE('fs2_blocks                        :' || v_fs2_blocks);
  DBMS_OUTPUT.PUT_LINE('fs2_bytes                         :' || v_fs2_bytes);
  DBMS_OUTPUT.PUT_LINE('fs3_blocks                        :' || v_fs3_blocks);
  DBMS_OUTPUT.PUT_LINE('fs3_bytes                         :' || v_fs3_bytes);
  DBMS_OUTPUT.PUT_LINE('fs4_blocks                        :' || v_fs4_blocks);
  DBMS_OUTPUT.PUT_LINE('fs4_bytes                         :' || v_fs4_bytes);
  DBMS_OUTPUT.PUT_LINE('full_blocks                       :' || v_full_blocks);
  DBMS_OUTPUT.PUT_LINE('full_bytes                        :' || v_full_bytes);
END;
/


