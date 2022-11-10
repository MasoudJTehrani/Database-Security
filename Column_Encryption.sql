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