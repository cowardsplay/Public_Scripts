<?php
//Created by Joshua Jenkins copy right 2025

//declare(strict_types=1);
// CORS headers to allow cross-origin requests
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET');
header('Access-Control-Allow-Headers: Content-Type');
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require './ClientBuilder.php';

//if (file_exists('./vendor/autoload.php')){
 //       echo "autoload file found.";

// Enable error reporting for debugging
//}
//else {
  //      echo "autoload file not found.";
    //    exit;
//}

require './vendor/autoload.php'; // Ensure Composer's autoloader is included
use Elastic\Elasticsearch\ClientBuilder;

// Connect to Elasticsearch
$client = ClientBuilder::create()


->setHosts(['https://<ip_ESS>:9200'])   //Specify the Ip Address of the ESS box 
->setBasicAuthentication('<ESS_username>','<ESS_password>')  // set username and password for the login creds of the ESS machine to grant access 
->setSSLVerification(false)
->build();

try {
    $params = [
        'index' => 'logs-*', // Replace with your Elasticsearch index name
        'body' => [
            'query' => [
                'bool' => [
                    'must' => [
                        ['match' => ['event.code' => '4624']], // Match event.code = 4624
                        ['exists' => ['field' => 'user.name']], // Ensure user.name exists
                        ['exists' => ['field' => 'host.name']]  // Ensure host.name exists
                    ],
                    'must_not' => [
                        ['match' => ['user.name' => 'EXCHANGE$']], // Exclude user EXCHANGE$
                        ['match' => ['user.name' => 'DC1$']],       // Exclude user DC1$
                        ['match' => ['user.name' => 'TECHSUPPORT$']], // Exclude user TECHSUPPORT$
                        ['match' => ['user.name' => 'DWM-6']],      // Exclude user DWM-6
                        ['match' => ['user.name' => 'DWM-7']],      // Exclude user DWM-7
                        ['match' => ['user.name' => 'UMFD-6']],     // Exclude user UMFD-6
                        ['match' => ['user.name' => 'UMFD-7']],     // Exclude user UMFD-7
                        ['match' => ['user.name' => 'CLIENT$']]     // Exclude user CLIENT$
                    ]
                ]
            ],
            '_source' => ['user.name', 'host.name', '@timestamp'] // Only fetch required fields
        ]
    ];

    $response = $client->search($params);

    // Return the results as JSON
    header('Content-Type: application/json');
    echo json_encode($response['hits']['hits'], JSON_PRETTY_PRINT);

} catch (Exception $e) {
    // Handle errors gracefully
    http_response_code(500);
    echo json_encode(['error' => 'elasticsearch error:'. $e->getMessage()]);
}

?>
