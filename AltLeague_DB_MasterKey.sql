

USE AltLeague;  
GO  

CREATE MASTER KEY ENCRYPTION BY   
PASSWORD = 'FwzXaeEixus8ib7Fvuth'; 

GO

CREATE CERTIFICATE AltLeague_PWD  
   WITH SUBJECT = 'AltLeague User Passwords';  
GO  

CREATE SYMMETRIC KEY AltLeague_PWD_Key 
    WITH ALGORITHM = AES_256  
    ENCRYPTION BY CERTIFICATE AltLeague_PWD;  
GO  





-- Create a column in which to store the encrypted data.  
ALTER TABLE dbo.app_User 
    ADD password_encrypted varbinary(128);   
GO  

-- Open the symmetric key with which to encrypt the data.  
OPEN SYMMETRIC KEY AltLeague_PWD_Key  
   DECRYPTION BY CERTIFICATE AltLeague_PWD;  

-- Encrypt the value in column NationalIDNumber with symmetric   
-- key SSN_Key_01. Save the result in column EncryptedNationalIDNumber.  
UPDATE dbo.app_User  
SET password_encrypted = EncryptByKey(Key_GUID('AltLeague_PWD_Key'), [password]);  
GO  

close symmetric key AltLeague_PWD_Key

-- Verify the encryption.  
-- First, open the symmetric key with which to decrypt the data.  
OPEN SYMMETRIC KEY AltLeague_PWD_Key  
   DECRYPTION BY CERTIFICATE AltLeague_PWD;  
GO  

-- Now list the original ID, the encrypted ID, and the   
-- decrypted ciphertext. If the decryption worked, the original  
-- and the decrypted ID will match.  
SELECT [password], password_encrypted   
    ,  
    CONVERT(varchar, DecryptByKey(password_encrypted))   
    AS password_unencrypted  
    FROM dbo.app_User;
GO  

close symmetric key AltLeague_PWD_Key