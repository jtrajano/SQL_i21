-- AdditionalGLAccts was removed, so update the current origin task
UPDATE tblICCompanyPreference
SET strOriginLastTask = 'Items'
WHERE strOriginLastTask = 'AdditionalGLAccts'