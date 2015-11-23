CREATE VIEW [dbo].[vyuCTEventMatrixDetailView]

AS

	SELECT		MD.intEventMatrixDetailId,	MD.intEventMatrixId,	MD.intPositionId,				MD.intWeightGradeId,
				MD.intEventId,				MD.intNoOfDays,			MD.intSort,						MD.ysnAffectAvlDate,
				ISNULL(MD.intPositionId,0)	intNNPositionId,		ISNULL(MD.intWeightGradeId,0)	intNNWeightGradeId,
		
				EV.strEventName,			PN.strPosition,			WG.strWeightGradeDesc,

				EM.strLoadingPointType,		EM.intLoadingPointId,	EM.strDestinationPointType,		EM.intDestinationPointId,

				LC.strCity	AS				strLoadingPoint,		DC.strCity AS					strDestinationPoint

		FROM	tblCTEventMatrixDetail	MD
		JOIN	tblCTEventMatrix		EM	ON	EM.intEventMatrixId		=	MD.intEventMatrixId
		JOIN	tblCTEvent				EV	ON	EV.intEventId			=	MD.intEventId			LEFT
		JOIN	tblCTPosition			PN	ON	PN.intPositionId		=	MD.intPositionId		LEFT
		JOIN	tblCTWeightGrade		WG	ON	WG.intWeightGradeId		=	MD.intWeightGradeId		LEFT
		JOIN	tblSMCity				LC	ON	LC.intCityId			=	EM.intLoadingPointId	LEFT
		JOIN	tblSMCity				DC	ON	DC.intCityId			=	EM.intDestinationPointId	
