CREATE PROCEDURE uspMFValidateDemand 
(
	@intLocationId INT = NULL
)
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @ErrMsg							NVARCHAR(MAX)
		  , @intDemandImportId				INT
		  , @intConcurrencyId				INT
		  , @strDemandNo					NVARCHAR(50)
		  , @strDemandName					NVARCHAR(100)
		  , @dtmDate						DATETIME
		  , @strBook						NVARCHAR(100)
		  , @strSubBook						NVARCHAR(100)
		  , @strItemNo						NVARCHAR(50)
		  , @strSubstituteItemNo			NVARCHAR(50)
		  , @dtmDemandDate					NVARCHAR(50)
		  , @dblQuantity					NUMERIC(18, 6)
		  , @strUnitMeasure					NVARCHAR(50)
		  , @strLocationName				NVARCHAR(50)
		  , @intCreatedUserId				INT
		  , @dtmCreated						DATETIME
		  , @intBookId						INT
		  , @intSubBookId					INT
		  , @intDemandHeaderImportId		INT
		  , @intDemandDetailImportId		INT
		  , @intItemId						INT
		  , @intUnitMeasureId				INT
		  , @intItemUOMId					INT
		  , @intDemandDetailId				INT
		  , @intSubstituteItemId			INT
		  , @strErrorMessage				NVARCHAR(MAX)
		  , @strDetailErrorMessage			NVARCHAR(MAX)
		  , @dtmMinDemandDate				DATETIME
		  , @dtmMaxDemandDate				DATETIME
		  , @intMinMonth					INT
		  , @intMaxMonth					INT
		  , @intMinYear						INT
		  , @intMaxYear						INT
		  , @intMinimumDemandMonth			INT
		  , @intMaximumDemandMonth			INT
		  , @intMonthDiff					INT
		  , @intImportCount					INT

	DECLARE @tblMFDemandHeaderImport TABLE 
	(
		intDemandHeaderImportId INT NOT NULL IDENTITY
	  , strDemandName			NVARCHAR(100) COLLATE Latin1_General_CI_AS
	  , dtmDate					DATETIME
	  , strBook					NVARCHAR(100) COLLATE Latin1_General_CI_AS
	  , strSubBook				NVARCHAR(100) COLLATE Latin1_General_CI_AS
	  , intCreatedUserId		INT
	  , dtmCreated				DATETIME NULL
	);

	DECLARE @tblMFDemandDetailImport TABLE 
	(
		intDemandDetailImportId		INT NOT NULL IDENTITY
	  , strDemandName				NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	  , strItemNo					NVARCHAR(50)	COLLATE Latin1_General_CI_AS
	  , strSubstituteItemNo			NVARCHAR(50)	COLLATE Latin1_General_CI_AS
	  , dtmDemandDate				NVARCHAR(50) COLLATE Latin1_General_CI_AS
	  , dblQuantity					NUMERIC(18, 6)
	  , strUnitMeasure				NVARCHAR(50) COLLATE Latin1_General_CI_AS
	  , strLocationName				NVARCHAR(50) COLLATE Latin1_General_CI_AS
	  , intDemandImportId			INT
	);

	SELECT @intMinimumDemandMonth = ISNULL(intMinimumDemandMonth, 12)
		 , @intMaximumDemandMonth = ISNULL(intMaximumDemandMonth, 12)
	FROM tblMFCompanyPreference

	BEGIN TRANSACTION

		/* Clear Demand Import Error Log. */
		DELETE FROM tblMFDemandImportError;

		INSERT INTO @tblMFDemandHeaderImport 
		(
			strDemandName
		  , dtmDate
		  , strBook
		  , strSubBook
		  , intCreatedUserId
		  , dtmCreated
		)
		SELECT DISTINCT strDemandName
					  , GETDATE()
					  , strBook
					  , strSubBook
					  , intCreatedUserId
					  , dtmCreated
		FROM tblMFDemandImport
		ORDER BY dtmCreated

		SELECT @intDemandHeaderImportId = MIN(intDemandHeaderImportId)
		FROM @tblMFDemandHeaderImport

		/* Loop Demand Header. */
		WHILE @intDemandHeaderImportId IS NOT NULL
			BEGIN
				SELECT @strDemandName			= NULL
					 , @dtmDate					= NULL
					 , @strBook					= NULL
					 , @strSubBook				= NULL
					 , @strItemNo				= NULL
					 , @strSubstituteItemNo		= NULL
					 , @dtmDemandDate			= NULL
					 , @dblQuantity				= NULL
					 , @strUnitMeasure			= NULL
					 , @intCreatedUserId		= NULL
					 , @dtmCreated				= NULL
					 , @intBookId				= NULL
					 , @intSubBookId			= NULL
					 , @strErrorMessage			= ''
					 , @intDemandDetailImportId = NULL

				SELECT @strDemandName		= strDemandName
					 , @dtmDate				= dtmDate
					 , @strBook				= strBook
					 , @strSubBook			= strSubBook
					 , @intCreatedUserId	= intCreatedUserId
					 , @dtmCreated			= dtmCreated
				FROM @tblMFDemandHeaderImport
				WHERE intDemandHeaderImportId = @intDemandHeaderImportId

				/* Validation Starts Here. */
				SELECT @intImportCount = COUNT(*) 
				FROM 
				(
					SELECT DISTINCT strBook
								  , strSubBook
					FROM @tblMFDemandHeaderImport
					WHERE strDemandName = @strDemandName
				) AS DT
				HAVING COUNT(*) > 1

				/* Check if Book and Sub Book for the Demand Name are all the same. */
				IF @intImportCount > 0
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + 'All the book and sub book name should be same for the demand name ' + @strDemandName + '. '
					END

				/* Check if the Demand Name was supplied. */
				IF @strDemandName IS NULL OR @strDemandName = ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + 'Demand Name cannot be empty. '
					END

				/* Check if the Demand Name already exists. */
				IF EXISTS (SELECT * FROM tblMFDemandHeader WHERE strDemandName = @strDemandName)
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + 'Demand Name already exists. '
					END

				SELECT @intBookId = intBookId
				FROM tblCTBook
				WHERE strBook = @strBook

				/* Check if the Book exists. */
				IF @intBookId IS NULL AND @strBook <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + 'Book ' + @strBook + ' does not exists. '
					END

				SELECT @intSubBookId = intSubBookId
				FROM tblCTSubBook
				WHERE strSubBook = @strSubBook

				IF @intSubBookId IS NULL AND @strSubBook <> ''
					BEGIN
						SELECT @strErrorMessage = @strErrorMessage + 'Sub Book ' + @strSubBook + ' does not exists. '
					END

				/* End of Validation. */

				DELETE FROM @tblMFDemandDetailImport;

				/* Staging Demand Import*/
				INSERT INTO @tblMFDemandDetailImport
				(
					strDemandName
				  , strItemNo
				  , strSubstituteItemNo
				  , dtmDemandDate
				  , dblQuantity
				  , strUnitMeasure
				  , strLocationName
				  , intDemandImportId
				)
				SELECT strDemandName
					 , strItemNo
					 , strSubstituteItemNo
					 , dtmDemandDate
					 , dblQuantity
					 , strUnitMeasure
					 , strLocationName
					 , intDemandImportId
				FROM tblMFDemandImport
				WHERE strDemandName = @strDemandName
				ORDER BY intDemandImportId

				SELECT @intDemandDetailImportId = MIN(intDemandDetailImportId)
				FROM @tblMFDemandDetailImport

				/* Loop Demand Detail Import. */
				WHILE @intDemandDetailImportId IS NOT NULL
					BEGIN
						SELECT @strItemNo				= NULL
							 , @strSubstituteItemNo		= NULL
							 , @dtmDemandDate			= NULL
							 , @dblQuantity				= NULL
							 , @strUnitMeasure			= NULL
							 , @strLocationName			= NULL
							 , @intSubstituteItemId		= NULL
							 , @intItemId				= NULL
							 , @intUnitMeasureId		= NULL
							 , @intLocationId			= NULL
							 , @strDetailErrorMessage	= ''
							 , @intDemandImportId		= NULL
							 , @dtmMinDemandDate		= NULL
							 , @dtmMaxDemandDate		= NULL
							 , @intMinMonth				= NULL
							 , @intMaxMonth				= NULL
							 , @intMinYear				= NULL
							 , @intMaxYear				= NULL

						SELECT @strItemNo			= strItemNo
							 , @strSubstituteItemNo = strSubstituteItemNo
							 , @dtmDemandDate		= dtmDemandDate
							 , @dblQuantity			= dblQuantity
							 , @strUnitMeasure		= strUnitMeasure
							 , @strLocationName		= strLocationName
							 , @intDemandImportId	= intDemandImportId
						FROM @tblMFDemandDetailImport
						WHERE intDemandDetailImportId = @intDemandDetailImportId

						IF (
							SELECT COUNT(*)
							FROM @tblMFDemandDetailImport
							WHERE strItemNo = @strItemNo
								AND ISNULL(strSubstituteItemNo, '') = ISNULL(@strSubstituteItemNo, ISNULL(strSubstituteItemNo, ''))
								AND ISNULL(strLocationName, '') = ISNULL(@strLocationName, IsNULL(strLocationName, ''))
								AND DATEPART(mm, dtmDemandDate) = DATEPART(mm, @dtmDemandDate)
								AND DATEPART(yy, dtmDemandDate) = DATEPART(yy, @dtmDemandDate)
							) > 1
							BEGIN
								IF @strSubstituteItemNo <> ''
									BEGIN
										SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'The item and substitute item ' + @strItemNo + ' and ' + @strSubstituteItemNo + ' is available multiple times for the same month. '
									END
								ELSE
									BEGIN
										SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'The item ' + @strItemNo + ' is available multiple times for the same month. '
									END
							END

						SELECT @dtmMinDemandDate = MIN(dtmDemandDate)
							 , @dtmMaxDemandDate = MAX(dtmDemandDate)
						FROM @tblMFDemandDetailImport
						WHERE strItemNo = @strItemNo
						  AND ISNULL(strSubstituteItemNo, '') = ISNULL(@strSubstituteItemNo, ISNULL(strSubstituteItemNo, ''))
						  AND ISNULL(strLocationName, '') = ISNULL(@strLocationName, ISNULL(strLocationName, ''))

						SELECT @intMinMonth = DATEPART(mm, @dtmMinDemandDate)
							 , @intMaxMonth = DATEPART(mm, @dtmMaxDemandDate)
							 , @intMinYear	= DATEPART(yy, @dtmMinDemandDate)
							 , @intMaxYear	= DATEPART(yy, @dtmMaxDemandDate)

						IF @intMinYear <> @intMaxYear
							BEGIN
								SELECT @intMaxMonth = @intMaxMonth + 12
							END

						SET @intMonthDiff = @intMaxMonth - @intMinMonth + 1;

						IF (@intMonthDiff > @intMaximumDemandMonth OR @intMonthDiff < @intMinimumDemandMonth) AND ISNULL(@strSubstituteItemNo, '') = ''
							BEGIN
								SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Demand date is not between minimum and maximum month for the item ' + @strItemNo + ' ';
							END

						IF ISNUMERIC(@dblQuantity) = 0
							BEGIN
								SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Quantity ' + ltrim(@dblQuantity) + ' is invalid. ';
							END

						IF @dblQuantity < 0
							BEGIN
								SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Quantity cannot be negative. ';
							END

						IF @dtmDemandDate IS NULL OR @dtmDemandDate = '1900-01-01 00:00:00.000' OR @dtmDemandDate = ''
							BEGIN
								SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Demand Date cannot be empty. ';
							END
						ELSE IF ISDATE(@dtmDemandDate) = 0
							BEGIN
								SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Demand Date ' + ltrim(@dtmDemandDate) + ' is invalid. ';
							END


						SELECT @intItemId = intItemId
						FROM tblICItem I
						WHERE I.strItemNo = @strItemNo

						/* Check if Item Exists. */
						IF @intItemId IS NULL AND @strItemNo <> ''
							BEGIN
								SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Item ' + @strItemNo + ' does not exists. '
							END

						SELECT @intSubstituteItemId = intItemId
						FROM tblICItem I
						WHERE I.strItemNo = @strSubstituteItemNo

						IF @intSubstituteItemId IS NULL AND @strSubstituteItemNo <> '' AND @intItemId IS NOT NULL
							BEGIN
								SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Substitute Item ' + @strSubstituteItemNo + ' is not available. '
							END
						ELSE IF @intSubstituteItemId IS NOT NULL AND NOT EXISTS (SELECT *
																				 FROM vyuMFGetDemandSubstituteItem
																				 WHERE intMainItemId = @intItemId 
																				   AND intItemId = @intSubstituteItemId)
																 AND @intItemId IS NOT NULL
							BEGIN
								SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Substitute item ' + @strSubstituteItemNo + ' is not configured for the item ' + @strItemNo + '. '
							END

						IF @strUnitMeasure IS NULL OR @strUnitMeasure = ''
							BEGIN
								SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Unit Measure cannot be empty. '
							END

						SELECT @intUnitMeasureId = intUnitMeasureId
						FROM tblICUnitMeasure U1
						WHERE U1.strUnitMeasure = @strUnitMeasure

						/* Check if Unit Measure Exists. */
						IF @intUnitMeasureId IS NULL AND @strUnitMeasure <> ''
							BEGIN
								SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Unit Measure ' + @strUnitMeasure + ' does not exists. '
							END

						SELECT @intItemUOMId = intItemUOMId
						FROM tblICItemUOM IU
						WHERE IU.intItemId = @intItemId AND IU.intUnitMeasureId = @intUnitMeasureId

						/* Check if Unit Measure is configured on Item. */
						IF @intItemUOMId IS NULL
							BEGIN
								SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Unit Measure ' + @strUnitMeasure + ' is not configured for the item ' + @strItemNo + '. '
							END
				
						SELECT @intLocationId = intCompanyLocationId
						FROM tblSMCompanyLocation
						WHERE strLocationName = @strLocationName

						/* Check if Company Location exists. */
						IF @intLocationId IS NULL AND @strLocationName <> ''
							BEGIN
								SELECT @strDetailErrorMessage = @strDetailErrorMessage + 'Location Name ' + @strLocationName + ' is not available. '
							END

						SELECT @strDetailErrorMessage = @strErrorMessage + @strDetailErrorMessage;

						IF @strDetailErrorMessage <> ''
							BEGIN

								/* Create Demand Error. */
								IF NOT EXISTS (SELECT 1 FROM tblMFDemandImportError WHERE intDemandImportId = @intDemandImportId)
									BEGIN
										INSERT INTO tblMFDemandImportError 
										(
											intDemandImportId
										  , intConcurrencyId
										  , strDemandName
										  , strBook
										  , strSubBook
										  , strItemNo
										  , strSubstituteItemNo
										  , dtmDemandDate
										  , dblQuantity
										  , strUnitMeasure
										  , strLocationName
										  , dtmCreated
										  , strErrorMessage
										  , intCreatedUserId
										)
										SELECT @intDemandImportId
											 , 1 
											 , @strDemandName
											 , @strBook
											 , @strSubBook
											 , @strItemNo
											 , @strSubstituteItemNo
											 , @dtmDemandDate
											 , @dblQuantity
											 , @strUnitMeasure
											 , @strLocationName
											 , @dtmCreated
											 , @strDetailErrorMessage
											 , @intCreatedUserId

									/* End of Create Demand Error. */
									END
							END
				
						/* Increment Loop Demand Detail Import. */ 
						SELECT @intDemandDetailImportId = MIN(intDemandDetailImportId)
						FROM @tblMFDemandDetailImport
						WHERE intDemandDetailImportId > @intDemandDetailImportId
			
			/* End of Loop Demand Detail Import. */ 
			END

			DELETE
			FROM @tblMFDemandHeaderImport
			WHERE strDemandName = @strDemandName

			/* Increment Loop Demand Header. */
			SELECT @intDemandHeaderImportId = MIN(intDemandHeaderImportId)
			FROM @tblMFDemandHeaderImport
			WHERE intDemandHeaderImportId > @intDemandHeaderImportId

		END

	SELECT intDemandImportErrorId
		 , intDemandImportId
		 , intConcurrencyId
		 , strDemandName
		 , strBook
		 , strSubBook
		 , strItemNo
		 , strSubstituteItemNo
		 , dtmDemandDate
		 , dblQuantity
		 , strUnitMeasure
		 , strLocationName
		 , intCreatedUserId
		 , dtmCreated
		 , strErrorMessage
	FROM tblMFDemandImportError

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION
		END

	SET @ErrMsg = ERROR_MESSAGE();

	RAISERROR 
	(
		@ErrMsg
	  , 16
	  , 1
	  , 'WITH NOWAIT'
	)
END CATCH
