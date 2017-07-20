<?php

include ('/var/www/html/inc/config.inc.php');

mysql_connect($db_host, $db_user, $db_pass);
mysql_select_db($db_name);

if(mysql_num_rows(mysql_query("SHOW TABLES LIKE '".$argv[1]."'"))==1) {
    $queries = file_get_contents($argv[2]);

    $queries = explode(";", $queries);

    foreach($queries as $query){
        mysql_query($query);
    }
}
