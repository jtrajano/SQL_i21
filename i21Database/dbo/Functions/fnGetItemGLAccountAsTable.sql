
CREATE FUNCTION [dbo].[fnGetItemGLAccountAsTable] (
	@intItemId INT
	,@intItemLocationId INT
	,@strAccountCategory NVARCHAR(255)
)
RETURNS TABLE 
RETURN (

	SELECT tblGLAccount.intAccountId	
	FROM	(
				-- Re-create the strAccountId (Original Account + Account Structure to modify)
				SELECT strAccountId = STUFF(
									(	
										SELECT	Divider.strMask + RecreateStructure.strCode
										FROM	tblGLAccountSegment RecreateStructure INNER JOIN (
													SELECT	intAccountSegmentId = 
																CASE	WHEN EXISTS (
																			-- Get the structure id for tblSMCompanyLocation.intProfitCenter. if it matches, use it as the override. 
																			SELECT	B.intAccountStructureId
																			FROM	tblGLAccountSegment A INNER JOIN tblGLAccountStructure B
																						ON A.intAccountStructureId = B.intAccountStructureId
																			WHERE	A.intAccountSegmentId = tblSMCompanyLocation.intProfitCenter
																					AND B.intAccountStructureId = Structure.intAccountStructureId
																		) 
																		THEN 
																			tblSMCompanyLocation.intProfitCenter 
																		ELSE 
																			SegmentMap.intAccountSegmentId 
																END 
															,Structure.intSort 
													FROM	tblGLAccountStructure Structure INNER JOIN tblGLAccountSegment Segment
																ON Structure.intAccountStructureId = Segment.intAccountStructureId

															INNER JOIN tblGLAccountSegmentMapping SegmentMap
																ON Segment.intAccountSegmentId = SegmentMap.intAccountSegmentId
																
															-- Join in this sub-query will get the base-account id 
															INNER JOIN (
																SELECT	intAccountId = ISNULL(ItemLevel.intAccountId, ISNULL(CategoryLevel.intAccountId, CompanyLocationLevel.intAccountId))
																FROM	(
																			-- Get the base acccount at the item-level
																			SELECT	TOP 1 
																					intAccountId
																			FROM	dbo.tblICItemAccount
																					INNER JOIN dbo.tblGLAccountCategory AccntCategory
																						ON tblICItemAccount.intAccountCategoryId = AccntCategory.intAccountCategoryId
																			WHERE	tblICItemAccount.intItemId = @intItemId
																					AND AccntCategory.strAccountCategory = @strAccountCategory
																		) AS ItemLevel
																		FULL JOIN (
																			-- Get the base account at the Item-Location level and then at the Category. 
																			SELECT	TOP 1 
																					CategoryAccounts.intAccountId
																			FROM	dbo.tblICItemLocation ItemLocation INNER JOIN dbo.tblICCategory Category
																						ON ItemLocation.intCategoryId = Category.intCategoryId
																					INNER JOIN tblICCategoryAccount CategoryAccounts
																						ON Category.intCategoryId = CategoryAccounts.intCategoryId
																					INNER JOIN dbo.tblGLAccountCategory AccntCategory
																						ON CategoryAccounts.intAccountCategoryId = AccntCategory.intAccountCategoryId
																			WHERE	ItemLocation.intItemId = @intItemId
																					AND ItemLocation.intItemLocationId = @intItemLocationId
																					AND AccntCategory.strAccountCategory = @strAccountCategory 			
																		) AS CategoryLevel
																			ON CategoryLevel.intAccountId = CategoryLevel.intAccountId
																		FULL JOIN (
																			-- Get the base account at the Company Location level																			
                                                                            SELECT    intAccountId = dbo.fnGetGLAccountFromCompanyLocation (tblICItemLocation.intLocationId, @strAccountCategory)
                                                                            FROM    tblICItemLocation 
                                                                            WHERE    tblICItemLocation.intItemLocationId = @intItemLocationId
                                                                                    AND tblICItemLocation.intItemId = @intItemId

																		) AS CompanyLocationLevel
																			ON CompanyLocationLevel.intAccountId = CompanyLocationLevel.intAccountId

															) ItemBaseGLAccountId
																ON SegmentMap.intAccountId = ItemBaseGLAccountId.intAccountId
															
															-- Join in this table will get the profit center (value of intAccountSegmentId as stored in tblSMCompanyLocation.intProfitCenter)
                                                            INNER JOIN tblICItemLocation 
                                                                ON tblICItemLocation.intItemLocationId = @intItemLocationId
                                                            INNER JOIN tblSMCompanyLocation
                                                                ON tblSMCompanyLocation.intCompanyLocationId = tblICItemLocation.intLocationId
																
													WHERE	Structure.strType <> 'Divider'
												) AS TemplateStructure 
													ON RecreateStructure.intAccountSegmentId = TemplateStructure.intAccountSegmentId
												,(
													SELECT TOP 1 
															strMask = ISNULL(strMask, '')
													FROM	tblGLAccountStructure
													WHERE	strType = 'Divider'
												) AS Divider							
										ORDER BY TemplateStructure.intSort
										FOR XML PATH('')
									)
									, 1
									, 1 -- We expect the divider used in COA setup is always one character. 
									, '' 
							)	
			) AS RecreatedAccount INNER JOIN tblGLAccount 
				-- To be sure, cross reference the re-created account id with the tblGLAccount table
				ON RecreatedAccount.strAccountId = tblGLAccount.strAccountId COLLATE Latin1_General_CI_AS
)
