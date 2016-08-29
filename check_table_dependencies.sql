SELECT owner, 
       constraint_name, 
       table_name 
FROM   dba_constraints 
WHERE  ( r_owner, r_constraint_name ) IN (SELECT owner, 
                                                            constraint_name 
                                                     FROM   dba_constraints 
                                                     WHERE 
              constraint_type IN ( 'P', 'U' ) 
              AND table_name = 'TABLE_NAME'); 