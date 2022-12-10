SPOOL /tmp/oracle/projectPart7_spool.txt

SELECT
    to_char(sysdate, 'DD Month YYYY Year Day HH:MI:SS AM')
FROM
    dual;

/* Question 1:
Run script 7Northwoods in schemas des03
Using CURSOR FOR LOOP syntax 1 in a procedure to display all the 
faculty member (f_id, f_last, f_first, f_rank), under each faculty member, 
display all the student advised by that faculty member
(s_id, s_last, s_first, birthdate, s_class). */
CONNECT des03/des03

SET SERVEROUTPUT ON

CREATE OR REPLACE PROCEDURE L7Q1 AS
CURSOR f_member_cur IS
    SELECT
        F_ID,
        F_LAST,
        F_FIRST,
        F_RANK
    FROM
        FACULTY;

CURSOR student_cur(p_f_id NUMBER) IS
    SELECT
        S_ID,
        S_LAST,
        S_FIRST,
        S_DOB,
        S_CLASS
    FROM
        STUDENT
    WHERE
        F_ID = p_f_id;

BEGIN
    FOR m IN f_member_cur LOOP
        DBMS_OUTPUT.PUT_LINE('----------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Faculty member: ' || m.F_ID || '. ' || m.F_LAST ||
                            ' ' || m.F_FIRST || ', ' || m.F_RANK);
    
        FOR s IN student_cur(m.F_ID) LOOP
            DBMS_OUTPUT.PUT_LINE('******************************');
            DBMS_OUTPUT.PUT_LINE('Student: ' || s.S_ID || '. ' || s.S_LAST ||
                                ' ' || s.S_FIRST || chr(10) ||
                                'Born: ' || s.S_DOB || chr(10) ||
                                'Class: ' || s.S_CLASS);
        END LOOP;
    
    END LOOP;
END;
/

EXEC L7Q1


/* Question 2:
Run script 7Software in schemas des04
Using %ROWTYPE in a procedure, display all the consultants. 
Under each consultant display all his/her skill (skill description) and the 
status of the skill (certified or not) */
CONNECT des04/des04

SET SERVEROUTPUT ON FORMAT WRAPPED

CREATE OR REPLACE PROCEDURE L7Q2 AS
CURSOR cons_cur IS
    SELECT
        C_ID,
        C_LAST,
        C_FIRST
    FROM
        CONSULTANT;
    v_cons_row cons_cur%ROWTYPE;
    
CURSOR skill_cur(p_C_ID NUMBER) IS
    SELECT
        CS.SKILL_ID,
        SKILL_DESCRIPTION,
        CERTIFICATION
    FROM
        CONSULTANT_SKILL cs JOIN
        SKILL s ON cs.SKILL_ID = s.SKILL_ID
    WHERE
        C_ID = p_C_ID;
    v_skill_row skill_cur%ROWTYPE;

BEGIN
    OPEN cons_cur;
    FETCH cons_cur INTO v_cons_row;
    WHILE cons_cur%FOUND LOOP
        DBMS_OUTPUT.PUT_LINE('------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Consultant: ' || v_cons_row.C_ID || '. ' || v_cons_row.C_LAST ||
                            ' ' || v_cons_row.C_FIRST);

        OPEN skill_cur(v_cons_row.C_ID);
        FETCH skill_cur INTO v_skill_row;
        WHILE skill_cur%FOUND LOOP
            DBMS_OUTPUT.PUT_LINE(chr(32) || chr(32) || '****************************************');
            DBMS_OUTPUT.PUT_LINE(chr(32) || chr(32) || 'Skill: ' || v_skill_row.SKILL_ID || '. ' || v_skill_row.SKILL_DESCRIPTION ||
                                chr(10) || chr(32) || chr(32) || 'Certification: ' || v_skill_row.CERTIFICATION);
            FETCH skill_cur INTO v_skill_row;
        END LOOP;
        CLOSE skill_cur;

        FETCH cons_cur INTO v_cons_row;
    END LOOP;
    CLOSE cons_cur;
END;
/

EXEC L7Q2


/* Question 3:
Run script 7Clearwater in schemas des02
Using CURSOR FOR LOOP syntax 2 in a procedure to display all items 
(item_id, item_desc, cat_id) under each item, display all the inventories 
belong to it. */
CONNECT des02/des02

SET SERVEROUTPUT ON FORMAT WRAPPED

CREATE OR REPLACE PROCEDURE L7Q3 AS
BEGIN
    FOR it IN (
                SELECT
                    ITEM_ID,
                    ITEM_DESC,
                    CAT_ID
                FROM
                    ITEM
                ) LOOP
        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Item: ' || it.ITEM_ID || '. ' || it.iTEM_DESC ||
                            ', Category ID: ' || it.CAT_ID);

        FOR inv IN (
                    SELECT
                        INV_ID,
                        COLOR,
                        INV_SIZE,
                        INV_PRICE,
                        INV_QOH
                    FROM
                        INVENTORY
                    WHERE
                        ITEM_ID = it.ITEM_ID
                    ) LOOP
            DBMS_OUTPUT.PUT_LINE(chr(32) || chr(32) || 'Inventory: ' || inv.INV_ID || '. ' || inv.COLOR ||
                                ', ' || inv.INV_SIZE || ', $' || inv.INV_PRICE || ', in STOCK: ' || inv.INV_QOH);
        END LOOP;
    END LOOP;
END;
/

EXEC L7Q3


/* Question 4:
Modify question 3 to display beside the item description the value of 
the item (value = inv_price * inv_qoh). */
CREATE OR REPLACE PROCEDURE L7Q4 AS
BEGIN
    FOR it IN (
                WITH x AS (
                            SELECT
                                ITEM_ID,
                                SUM(INV_PRICE * INV_QOH) AS VALUE
                            FROM
                                INVENTORY
                            GROUP BY
                                ITEM_ID
                            )
                SELECT
                    it.ITEM_ID,
                    ITEM_DESC,
                    CAT_ID,
                    VALUE
                FROM
                    ITEM it JOIN
                    x val ON it.ITEM_ID = val.ITEM_ID
                ) LOOP
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Item: ' || it.ITEM_ID || '. ' || it.iTEM_DESC || ', VALUE: $' || it.VALUE ||
                            ', Category ID: ' || it.CAT_ID);

        FOR inv IN (
                    SELECT
                        INV_ID,
                        COLOR,
                        INV_SIZE,
                        INV_PRICE,
                        INV_QOH
                    FROM
                        INVENTORY
                    WHERE
                        ITEM_ID = it.ITEM_ID
                    ) LOOP
            DBMS_OUTPUT.PUT_LINE(chr(32) || chr(32) || 'Inventory: ' || inv.INV_ID || '. ' || inv.COLOR ||
                                ', ' || inv.INV_SIZE || ', $' || inv.INV_PRICE || ', in STOCK: ' || inv.INV_QOH);
        END LOOP;
    END LOOP;
END;
/

EXEC L7Q4


SPOOL OFF;