<?php
include ('/var/www/html/inc/config.inc.php');

global $db_host;
global $db_user;
global $db_pass;
global $db_name;

mysql_connect($db_host, $db_user, $db_pass);
mysql_select_db($db_name);

if(mysql_num_rows(mysql_query("SHOW TABLES LIKE '".$argv[1]."'"))==0) {
    $queries = file_get_contents($argv[2]);
    
    $queries = explode(";", $queries);

    foreach($queries as $query) {
        if (trim($query)) {
            if (@mysql_query($query)==false)  {
                exit(1);
            }
        }
    }
}
