CREATE VIEW [dbo].[vyuSMImportFieldMapping]
	AS

SELECT intFieldMapId = FieldMap.intImportFileHeaderId
	, FieldMap.strLayoutTitle
	, FieldMap.strFileType
	, FieldMap.strFieldDelimiter
	, FieldMap.strXMLType
	, FieldMap.strXMLInitiater
	, intIdentifierId = Identifier.intImportFileRecordMarkerId
	, Identifier.strRecordMarker
	, intIdentifierPosition = Identifier.intPosition
	, Identifier.intSequence
	, Identifier.intRowsToSkip
	, Identifier.strFormat
	, Identifier.strCondition
	, intColumnId = ColumnMap.intImportFileColumnDetailId
	, ColumnMap.strColumnName
	, ColumnMap.strDataType
	, intColumnPosition = ColumnMap.intPosition
	, ColumnMap.intLength
	, ColumnMap.intLevel
FROM tblSMImportFileHeader FieldMap
LEFT JOIN tblSMImportFileRecordMarker Identifier ON Identifier.intImportFileHeaderId = FieldMap.intImportFileHeaderId
LEFT JOIN tblSMImportFileColumnDetail ColumnMap ON ColumnMap.intImportFileRecordMarkerId = Identifier.intImportFileRecordMarkerId
WHERE FieldMap.intImportFileHeaderId = 11
	AND FieldMap.ysnActive = 1
	AND ColumnMap.ysnActive = 1