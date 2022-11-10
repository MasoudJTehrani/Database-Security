--Transparent Data Encryption (TDE)
--go to master level
USE Master;
GO
create master key encryption by password = 'SomeThing Very Strong144@';
CREATE CERTIFICATE TDE_Cert WITH SUBJECT='TDE_Encryption';

--go back to DB level
USE ShirazuCompany;
GO
--creating encryption key
CREATE DATABASE ENCRYPTION KEY WITH ALGORITHM = AES_128 ENCRYPTION BY SERVER CERTIFICATE TDE_Cert;
--turning on the encryption
ALTER DATABASE ShirazuCompany SET ENCRYPTION ON;

--backing up the certificate
BACKUP CERTIFICATE TDE_Cert
TO FILE = 'C:\temp\TDE_Cert'
WITH PRIVATE KEY (file='C:\temp\TDE_CertKey.pvk',
ENCRYPTION BY PASSWORD='SomeThing Very Strong144@') 

--restoring the certificate
USE Master;
GO
CREATE MASTER KEY ENCRYPTION
BY PASSWORD='SomeThing Very Strong144@';

CREATE CERTIFICATE TDECert
FROM FILE = 'C:\Temp\TDE_Cert'
WITH PRIVATE KEY (FILE = 'C:\TDECert_Key.pvk',
DECRYPTION BY PASSWORD = 'SomeThing Very Strong144@' );