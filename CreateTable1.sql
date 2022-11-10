USE ShirazuCompany;
go



CREATE TABLE Customers(
	[CustomerNumber] int NOT NULL,
	[FirstName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[Phone] [varchar](50) NULL,
	[Address] [varchar](50) NULL,
	[City] [varchar](50) NULL,
	[State] [varchar](50) NULL,
	[Zip] [varchar](10) NULL,
	[Email] [varchar](50) NULL,
	[Birthdate] [varchar](50) NULL,
	[Anniversary] [varchar](50) NULL,
	[CCNumber] [varchar](20) NULL
	CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED 
	(
	[CustomerNumber] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

/********************************/


BULK 
INSERT Customers
        FROM 'E:\Uni Arshad\Data base security\Projects\DB Sec HWs\HW#2\customersData.csv'
            WITH
    (
                FIELDTERMINATOR = ',',
                ROWTERMINATOR = '\n'
    )
GO

--Column Encryption
select * from Customers;
ALTER DATABASE ShirazuCompany SET COMPATIBILITY_LEVEL = 120;
 
SELECT compatibility_level FROM sys.databases WHERE name = 'ShirazuCompany'; 

-- Create masterkey
create master key encryption by password = 'SomeThing Very Strong144@';
select * from sys.symmetric_keys;


-- Create Certificate
create certificate MyCCNCertificate with subject = 'MY CCN Test Certificate';
select * from sys.certificates;


-- Create a symmetric key
create symmetric key CCNSymKey with algorithm = triple_des encryption by certificate MyCCNCertificate;
select * from sys.symmetric_keys;


-- Create a column to save the encrypted data
alter table Customers add CCN_Encrypted varbinary(160);
select * from Customers;

-- Open our encryption key
open symmetric key CCNSymKey decryption by certificate MyCCNCertificate;
-- Encrypt the data
update Customers set CCN_Encrypted = EncryptByKey(Key_Guid('CCNSymKey'), CCNumber);
-- Close our key
close symmetric key CCNSymKey;
select * from Customers;

--Decryption
-- Open the key for use, like before
open symmetric key CCNSymKey decryption by certificate MyCCNCertificate;
-- Decrypt our data
SELECT CCNumber, CCN_Encrypted   
    AS 'Encrypted CC Number',  
    CONVERT(varchar(20), DecryptByKey(CCN_Encrypted))   
    AS 'Decrypted CC Number'  
    FROM Customers;  
-- Close our key, like before
close symmetric key CCNSymKey;

ALTER TABLE Customers DROP COLUMN CCNumber;

--Deleting keys and certificate
DROP MASTER KEY;
DROP CERTIFICATE MyCCNCertificate;
DROP SYMMETRIC KEY CCNSymKey;

--exporting the result table into a csv file

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