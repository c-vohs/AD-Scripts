import-module activedirectory

$default_log = 'c:\kworking\User_Password_Report.csv'

 

#enumerate all the domain in a forest

foreach($domain in (get-adforest).domains){

    #query all users except critical system objects
    get-aduser -LDAPFilter "(!(IsCriticalSystemObject=TRUE))" `
    -properties enabled,whencreated,whenchanged,lastlogontimestamp,PwdLastSet,PasswordExpired,DistinguishedName,servicePrincipalName `
    -server $domain |`
    select @{name='Domain';expression={$domain}},`
    SamAccountName,enabled,PasswordExpired,`
    @{Name="PwdLastSet";Expression={[datetime]::FromFileTime($_.PwdLastSet)}}, `
    @{Name="PwdAge";Expression={if($_.PwdLastSet -ne 0){(new-TimeSpan([datetime]::FromFileTimeUTC($_.PwdLastSet)) $(Get-Date)).days}else{0}}}, `
    @{Name="LastLogonTimeStamp";Expression={[datetime]::FromFileTime($_.LastLogonTimeStamp)}}, `
    whenchanged,whencreated,
    @{Name="HasServicePrincipal";Expression={if($_.servicePrincipalName){$True}else{$False}}}, `
    distinguishedname | export-csv $default_log -NoTypeInformation}