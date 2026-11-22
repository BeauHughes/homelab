Add-Computer -DomainName "lab.internal" -Credential LAB\beau.admin `
  -OUPath "OU=Lab Computers,OU=LAB,DC=lab,DC=internal" -Restart