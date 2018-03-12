-- AdditionalGLAccts was removed, so update the current origin task
SELECT * FROM tblICCompanyPreference
UPDATE tblICCompanyPreference
SET strOriginLastTask = 'Items'
WHERE strOriginLastTask = 'AdditionalGLAccts'