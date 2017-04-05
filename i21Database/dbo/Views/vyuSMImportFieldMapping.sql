CREATE VIEW [dbo].[vyuSMImportFieldMapping]
	AS

SELECT intFieldMapId = FieldMap.intImportFileHeaderId
	, FieldMap.strLayoutTitle
	, FieldMap.strFileType
	, FieldMap.strFieldDelimiter
	, FieldMap.strXMLType
	, FieldMap.strXMLInitiater
	, ColumnDetail.intImportFileColumnDetailId
	, ColumnDetail.strTable
	, ColumnDetail.strColumnName
	, RecordMarker.intImportFileRecordMarkerId
	, RecordMarker.strRecordMarker
	, RecordMarker.intRowsToSkip
	, RecordMarker.intPosition
	, RecordMarker.strCondition
	, RecordMarker.intSequence
	, RecordMarker.strFormat
	, RecordMarker.intRounding
FROM tblSMImportFileHeader FieldMap
LEFT JOIN tblSMImportFileRecordMarker RecordMarker ON RecordMarker.intImportFileHeaderId = FieldMap.intImportFileHeaderId
LEFT JOIN tblSMImportFileColumnDetail ColumnDetail ON ColumnDetail.intImportFileRecordMarkerId = RecordMarker.intImportFileRecordMarkerId
WHERE ISNULL(FieldMap.ysnActive, 0) = 1
	AND ISNULL(ColumnDetail.ysnActive, 0) = 1
	AND ISNULL(ColumnDetail.intImportFileColumnDetailId, '') <> ''