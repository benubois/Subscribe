<?php
$request_headers = array();
$approved_headers = array('Authorization', 'Content-type', 'Content-length');

foreach (apache_request_headers() as $key => $value) 
{
	if (in_array($key, $approved_headers))
	{
		array_push($request_headers, "{$key}: {$value}");
	}
}
if (condition)
{
	# code...
}

error_log(var_export($request_headers, TRUE));

function http_request($url, $headers)
{
	if (!empty($_GET)) 
	{
		$url = $url . '?' . http_build_query($_GET);
	}

	$ch = curl_init();
	curl_setopt($ch, CURLOPT_URL, $url);

	if ('POST' == $_SERVER['REQUEST_METHOD'])
	{
		if ('POST' == $_SERVER['REQUEST_METHOD'])
		$headers["Content-Length"] = '0';
		curl_setopt($ch, CURLOPT_POST, 1);
		curl_setopt($ch, CURLOPT_POSTFIELDS, http_build_query($_POST));
	}

	curl_setopt($ch, CURLOPT_FAILONERROR, 0);
	curl_setopt($ch, CURLOPT_FRESH_CONNECT, 1);
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, 0);
	curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 0);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 0);
	curl_setopt($ch, CURLOPT_TIMEOUT, 30);
	curl_setopt($ch, CURLOPT_HEADER, 1); 
	
	curl_setopt($ch,CURLOPT_HTTPHEADER, $headers);
	
	$retval = curl_exec($ch);
	
	$parts = explode("\n\r\n", $retval);
	$headers = explode("\n", $parts[0]);
	$body = $parts[1];
	
	$curl_error = curl_error($ch);
	$curl_getinfo = curl_getinfo($ch);
	$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
	curl_close($ch);

	return array("curl_body" => $body, "curl_headers" => $headers, "curl_error" => $curl_error, "curl_getinfo" => $curl_getinfo, "http_code" => $http_code);
}

$result = http_request("https://www.google.com{$_SERVER['PATH_INFO']}", $request_headers);

error_log(var_export($result, TRUE));

header($result['curl_headers'][0]);
print $result['curl_body'];