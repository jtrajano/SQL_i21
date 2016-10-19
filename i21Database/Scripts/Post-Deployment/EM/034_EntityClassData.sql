

PRINT '*** ----  Start checking entity class information  ---- ***'

IF(NOT EXISTS(SELECT TOP 1 1 from tblEMEntityClass where intEntityClassId = 1))
BEGIN
	INSERT INTO tblEMEntityClass(intEntityClassId, strClass, strModule, ysnActive)
	SELECT 1, 'Customer base', 'AP', 1
END
ELSE
BEGIN
	UPDATE tblEMEntityClass SET strClass = 'Customer base', strModule = 'AP',ysnActive = 1  where intEntityClassId = 1
END


IF(NOT EXISTS(SELECT TOP 1 1 from tblEMEntityClass where intEntityClassId = 2))
BEGIN
	INSERT INTO tblEMEntityClass(intEntityClassId, strClass, strModule, ysnActive)
	SELECT 2, 'Cendor base', 'AP', 1
END
ELSE
BEGIN
	UPDATE tblEMEntityClass SET strClass = 'Cendor base', strModule = 'AP',ysnActive = 1  where intEntityClassId = 2
END

PRINT '*** ----  End checking entity class information  ---- ***'