<?php

$srv  = "ldap://ip";

$usr  = "CN=php-ldap-principal,OU=Principals,DC=abstergo,DC=internal";

$pass = "";

#

$conn=ldap_connect($srv);

ldap_set_option($conn, LDAP_OPT_PROTOCOL_VERSION, 3);

ldap_set_option($conn, LDAP_OPT_REFERRALS, 0);

#

$result=ldap_bind($conn, $usr , $pass);

if (! $result) { die("$srv:Connection failed ..."); }

else { echo "<p>$srv: Connection succeeded ...</p>"; }

$dn="OU=Employees,DC=abstergo,DC=internal";

$search='(cn=*)';

#

$sr=ldap_search($conn, $dn, $search);

$data = ldap_get_entries($conn, $sr);

echo "<p>Employees of $dn:</p>";

echo "<p>Employees count: ".$data["count"]."</p>";

#
echo "<ul>";
for ($i=0; $i<$data["count"]; $i++) {

        echo "<li>DN=(".$data[$i]["dn"].")</li>";

}
echo "</ul>";

ldap_close($conn);
