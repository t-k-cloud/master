<?php
if (!function_exists('getallheaders'))
{
	function getallheaders() {
		$headers = [];
		foreach ($_SERVER as $name => $value) {
			if (substr($name, 0, 5) == 'HTTP_') {
				$key = str_replace(' ', '-', ucwords(strtolower(
				                   str_replace('_', ' ', substr($name, 5)))
				                  ));
				array_push($headers, "$key: $value");
			}
		}
		return $headers;
	}
}

function getCookieHeaders()
{
	$CokHeaders = [];
	$allHeaders = getallheaders();
	foreach ($allHeaders as $hf) {
		if (preg_match("/^Cookie:/i", $hf)) {
			array_push($CokHeaders, $hf);
		}
	}
	return $CokHeaders;
}

/* create curl POST fields from $_POST and $_FILES. */
function curl_postfields()
{
	$file_array = array();
	foreach ($_FILES as $k => $v) {
		if (is_array($v['tmp_name'])) {
			$file_array[$k] = curl_file_create(
				$v['tmp_name'][0], // file path
				$v['type'][0],     // MIME type
				$v['name'][0]      // upload name
			);
		} else {
			$file_array[$k] = curl_file_create(
				$v['tmp_name'], // file path
				$v['type'],     // MIME type
				$v['name']      // upload name
			);
		}
	}

	return array_merge($_POST, $file_array);
}

$DEFAULT_PROXY_PORT = 8991;
$req_uri = $_SERVER['REQUEST_URI'];
$useragent = $_SERVER['HTTP_USER_AGENT'];
$matches = array(); // match results
$proxy_port = 0;
$proxy_uri = '';
if (preg_match('/^\/r\/([0-9]+)(.*)/', $req_uri, $matches)) {
	// matching: http://hostname/r/54321/some/path/somefile
	$proxy_port = $matches[1];
	$proxy_uri = $matches[2];
} else if (preg_match('/^\/r\/(.*)/', $req_uri, $matches)) {
	// matching: http://hostname/r/some/path/somefile
	$proxy_port = $DEFAULT_PROXY_PORT;
	$proxy_uri = "/$matches[1]";
} else {
	echo "ERROR: unexpected URI proxy request: `$req_uri'.";
	exit;
}

/* curl instance setup */
$ch = curl_init();
$proxy = "http://localhost:${proxy_port}";
$url = "http://127.0.0.1$proxy_uri";
$ret_header_proxy = true;

//curl_setopt($ch, CURLOPT_COOKIE, $cookie);
curl_setopt($ch, CURLOPT_PROXY, $proxy);
curl_setopt($ch, CURLOPT_PROXYTYPE, CURLPROXY_SOCKS5);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, 1);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLINFO_HEADER_OUT, true);
curl_setopt($ch, CURLOPT_USERAGENT, $useragent);

// if request method is POST (most of the time it is GET)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
	curl_setopt($ch, CURLOPT_POST, 1); /* set request as POST */
	curl_setopt($ch, CURLOPT_TIMEOUT, 60); /* 1 minute timeout */

	/* copy origin request POST fields */
	$raw_post = file_get_contents("php://input");
	if ('' == $raw_post) {
		$post = curl_postfields();

		curl_setopt($ch, CURLOPT_POSTFIELDS, $post);
		curl_setopt($ch, CURLOPT_HTTPHEADER, getCookieHeaders());
		$ret_header_proxy = false;
	} else {
		curl_setopt($ch, CURLOPT_POSTFIELDS, $raw_post);
		curl_setopt($ch, CURLOPT_HTTPHEADER, getallheaders());
	}
} else {
	curl_setopt($ch, CURLOPT_HTTPHEADER, getallheaders());
}

curl_setopt($ch, CURLOPT_HEADER, $ret_header_proxy);
$ret = curl_exec($ch); // do the actual curl

if (curl_errno($ch)) {
	/* show error string on curl error */
	$errstr = curl_error($ch);
	exit("ERROR: PHP-curl `$errstr'.");
}

if ($ret_header_proxy) {
	/* return response header */
	list($ret_header, $ret_body) = explode("\r\n\r\n", $ret, 2);
	$ret_header_arr = explode("\r\n", $ret_header);
	foreach ($ret_header_arr as $hf) {
		header($hf);
	}

	/* return response body */
	echo $ret_body;
} else {
	echo $ret;
}

//ob_start();
//echo "===== \n";
////var_dump($ret_header);
//var_dump(getallheaders());
//file_put_contents('revprox.log', ob_get_clean(), FILE_APPEND | LOCK_EX);

curl_close($ch); // close curl instance
?>
