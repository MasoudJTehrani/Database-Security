CREATE DATABASE DBSecShiraz
GO
USE DBSecShiraz
GO
CREATE TABLE HW4DBSecTable
(
 [ID] int,
 [Family] varchar(50),
 [Degree] varchar(50)
)
GO
INSERT INTO HW4DBSecTable VALUES (1,'DrFakhrahmad','A')
INSERT INTO HW4DBSecTable VALUES (2,'Abdullah','A')
INSERT INTO HW4DBSecTable VALUES (3,'khalili','A')
INSERT INTO HW4DBSecTable VALUES (4,'Mohammad','B')
INSERT INTO HW4DBSecTable VALUES (5,'Yazdani','B')
INSERT INTO HW4DBSecTable VALUES (6,'Mostafa','B')
INSERT INTO HW4DBSecTable VALUES (7,'Mohammadpourfard','A')
GO

--creating users.
CREATE USER UserDegreeA WITHOUT LOGIN;
CREATE USER UserDegreeB WITHOUT LOGIN;

--Granting read access on the table to each of the users.
GRANT SELECT ON HW4DBSecTable TO UserDegreeA;
GRANT SELECT ON HW4DBSecTable TO UserDegreeB;

--create a new schema.
CREATE SCHEMA Security;

--creating an inline table-viewed function.
CREATE FUNCTION Security.tvf_securitypredicate(@Degree AS varchar(50))  
    RETURNS TABLE  
WITH SCHEMABINDING  
AS  
    RETURN SELECT 1 AS tvf_securitypredicate_result
WHERE @Degree = RIGHT(USER_NAME(),1);

--Create a security policy adding the function as a filter predicate.
CREATE SECURITY POLICY shirazFilter  
ADD FILTER PREDICATE Security.tvf_securitypredicate(Degree)
ON dbo.HW4DBSecTable
WITH (STATE = ON);

--Allow SELECT permissions to the fn_securitypredicate function
GRANT SELECT ON Security.tvf_securitypredicate TO UserDegreeA;  
GRANT SELECT ON Security.tvf_securitypredicate TO UserDegreeB;

--testing
EXECUTE('Select * from HW4DBSecTable;') AS USER ='UserDegreeA';
EXECUTE('Select * from HW4DBSecTable;') AS USER ='UserDegreeB';