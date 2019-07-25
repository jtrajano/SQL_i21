Print 'BEGIN UPDATE BROKERAGE COMMISSION PROCESSING strComments from strCode instead of strTitle'
if exists(select * from tblCTBrkgCommn where strComments in (select strTitle from tblSMDocumentMaintenance))
begin
update tblCTBrkgCommn set strComments = (select strCode from tblSMDocumentMaintenance where strTitle = strComments) where strComments in (select strTitle from tblSMDocumentMaintenance)
end
Print 'END UPDATE BROKERAGE COMMISSION PROCESSING strComments to strTitle'