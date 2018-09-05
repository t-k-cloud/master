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
if (preg_match('/^\/(.*)/', $req_uri, $matches)) {
	$proxy_port = $DEFAULT_PROXY_PORT;
	$proxy_uri = "/$matches[1]";
} else {
	echo "ERROR: unexpected URI proxy request: `$req_uri'.";
	exit;
}

/* curl instance setup */
$mh = curl_multi_init();
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
curl_setopt($ch, CURLOPT_TIMEOUT, 60 * 60); /* 60 minutes timeout */
//curl_setopt($ch, CURLOPT_TCP_NODELAY, true);

// if request method is POST (most of the time it is GET)
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
	curl_setopt($ch, CURLOPT_POST, 1); /* set request as POST */

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

// if (true) { /* uncomment this line to debug (curl_multi_exec won't report any error) */
if (!$ret_header_proxy) {
	$ret = curl_exec($ch);
	if (curl_errno($ch)) {
		/* show error string on curl error */
		$errstr = curl_error($ch);
		echo("proxy=`$proxy', url=`$url'"."<br/>");
		exit("revprox PHP-curl error: `$errstr'.");
	}
	echo $ret;
	curl_close($ch); // close curl instance
	exit();
}

/* start to execute using non-blocking curl_multi_*() */
curl_multi_add_handle($mh, $ch);
$running = null;
$offset  = 0;
do {
	$status = curl_multi_exec($mh, $running);
	if($status != CURLM_OK) {
		$errstr = curl_multi_strerror($status);
		echo("proxy=`$proxy', url=`$url'"."<br/>");
		exit("curl_multi_exec error: `$errstr'.");
	}
	$content = curl_multi_getcontent($ch);

	if ($offset == 0 && strpos($content, "\r\n\r\n")) {
		list($ret_header, $ret_body) = explode("\r\n\r\n", $content, 2);
		$ret_header_arr = explode("\r\n", $ret_header);
		foreach ($ret_header_arr as $hf) { header($hf); }
		echo $ret_body;
		$offset = strlen($content);
	} else if ($offset > 0) {
		echo substr($content, $offset);
		$offset = strlen($content);
		usleep(54321); //sleep
		// file_put_contents('/tmp/revprox.log', "$offset\n" , FILE_APPEND | LOCK_EX);
	}
} while ($running > 0);

curl_multi_remove_handle($mh, $ch);
curl_multi_close($mh);
curl_close($ch); // close curl instance
?>
