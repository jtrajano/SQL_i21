IF NOT EXISTS(SELECT 1 FROM tblSMScreen WHERE strNamespace = 'Mobilebilling.view.LongTruck')
BEGIN
INSERT INTO tblSMScreen(strScreenId,strScreenName,strNamespace,strModule,ysnAvailable) 
VALUES('','Long Truck','Mobilebilling.view.LongTruck','Mobile Billing',1)
END