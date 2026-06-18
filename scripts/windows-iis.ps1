<powershell>
Install-WindowsFeature -Name Web-Server -IncludeManagementTools

Set-Content -Path "C:\inetpub\wwwroot\index.html" -Value @"
<html>
  <body>
    <h1>Hello from Windows IIS</h1>
    <p>Windows Server 2022 deployed with Terraform</p>
  </body>
</html>
"@
</powershell>