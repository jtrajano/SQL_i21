CREATE VIEW [dbo].[vyuSMImportFieldMapping]
	AS

SELECT intFieldMapId = FieldMap.intImportFileHeaderId
	, FieldMap.strLayoutTitle
	, FieldMap.strFileType
	, FieldMap.strFieldDelimiter
	, FieldMap.strXMLType
	, FieldMap.strXMLInitiater
	, RecordMarker.intImportFileRecordMarkerId
	, RecordMarker.strRecordMarker
	, RecordMarker.intRowsToSkip
	, RecordMarker.intPosition
	, RecordMarker.strCondition
	, RecordMarker.intSequence
	, RecordMarker.strFormat
FROM tblSMImportFileHeader FieldMap
LEFT JOIN tblSMImportFileRecordMarker RecordMarker ON RecordMarker.intImportFileHeaderId = FieldMap.intImportFileHeaderId
WHERE FieldMap.ysnActive = 1