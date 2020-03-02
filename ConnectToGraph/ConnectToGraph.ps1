#Clear Console
cls

#*** Initialize variables
Write-Host "Initialize variables"
Write-Host " "

[string]$graphApp_AppId = "APPLICATION_ID"
[string]$graphApp_AppSecret = "APPLICATION_SECRET"
[string]$tenantId="TENANT_ID"
[string]$spAdminURL = "SPADMIN_URL"
[string]$graphVer = "v1.0"

#Credetential iformation to be used in delegated connections
[string]$username = "USERNAME"
[string]$password = "PASSWORD"

#Start the process
Write-Host "Start the process"
Write-Host (Get-Date).ToString()

try{

    #Connecting with Application Permissions
    Write-Host " "
    Write-Host "Connecting with Application Permissions"

    $body=@{
        client_id=$graphApp_AppId
        client_secret=$graphApp_AppSecret
        scope="https://graph.microsoft.com/.default"
        grant_type="client_credentials"
    }

    $response = Invoke-WebRequest -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -ContentType "application/x-www-form-urlencoded" -Body $body -Method Post

    $accessToken=$response.content | ConvertFrom-Json
    $AppAccessToken = $accessToken.access_token
	
	if($AppAccessToken){
		Write-Host ("...got AppAccessToken")
	}
	else{
		Write-Error -Message$ "Application access error" -Category AuthenticationError
	}
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host "**ERROR: Connecting with Application Permissions"
    Write-Error -Message $ErrorMessage
}

try{

    #Connecting with Delegated permissions
    Write-Host " "
    Write-Host "Connecting with Delegated permissions"

    $body=@{
        client_id=$graphApp_AppId
        password= $password
        username= $username
        client_secret=$graphApp_AppSecret
        grant_type="password"
        scope="https://graph.microsoft.com/.default"
    }

    $response = Invoke-WebRequest -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" -ContentType "application/x-www-form-urlencoded" -Body $body -Method Post

    $accessToken=$response.content | ConvertFrom-Json
    $UserAccessToken = $accessToken.access_token
	
	if($UserAccessToken){
		Write-Host ("...got UserAccessToken")
	}
	else{
		Write-Error -Message$ "Delegated access error" -Category AuthenticationError
	}
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host "**ERROR: Connecting with Delegated permissions"
    Write-Error -Message $ErrorMessage
}

try{

    #Connecting with PnP PowerShell
    Write-Host " "
    Write-Host "Connecting with PnP PowerShell"

    Connect-PnPOnline -Url $spAdminURL -AppId $graphApp_AppId -AppSecret $graphApp_AppSecret
    $pnpAccessToken = Get-PnPAccessToken

	if($pnpAccessToken){
		Write-Host ("...got pnpAccessToken")
	}
	else{
		Write-Error -Message$ "PnP PowerShell access error" -Category AuthenticationError
	}
}
catch {
    $ErrorMessage = $_.Exception.Message
    Write-Host "**ERROR: Connecting with Delegated permissions"
    Write-Error -Message $ErrorMessage
}
