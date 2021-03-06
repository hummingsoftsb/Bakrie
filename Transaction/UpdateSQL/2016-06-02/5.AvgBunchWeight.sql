
/****** Object:  StoredProcedure [Weighbridge].[WBAverageBunchWeightProcess]    Script Date: 8/6/2016 1:27:03 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
----------------------------------------------------------
-- =============================================
-- Created By :  Ahmed Nazim
-- Modified By: 
-- Created date: 18/9/2013
-- Last Modified Date:
-- Module     : WeighBridge
-- Screen(s)  :
-- Description: Calculation of Average Bunch Weight
-- =============================================
ALTER PROCEDURE [Weighbridge].[WBAverageBunchWeightProcess] 
	@EstateID nvarchar(50),
	@ActiveMonthYearID nvarchar(50),
	@NumberOfMonths as int,
	@CalculateOnly as bit,
	@ModifiedBy nvarchar(50)
AS

BEGIN TRY
	
	-- GET the latest ActiveMonthYearID based on NumberOfMonths

		DECLARE @CurrentDate as smalldatetime
		DECLARE @PreviousMonth as smalldatetime

		select @CurrentDate = CAST(AYear as Varchar(10)) + '-' + CAST(AMonth as Varchar(10)) + '-01'  
		from General.ActiveMonthYear where ModID = 4 AND ActiveMonthYearID = @ActiveMonthYearID

		select TOP 12 CAST( CAST(AYear as Varchar(10)) + '-' + CAST(AMonth as Varchar(10)) + '-01' as SmallDateTime) as ADate, ActiveMonthYearID 
		INTO #tempActiveMonths
		from General.ActiveMonthYear where ModID = 4 AND AYear <= DATEPART(yyyy, @CurrentDate) AND AMonth <= DATEPART(MM, @CurrentDate) ORDER By AYear DESC, AMonth DESC

		-- delete all other months and keep only the months we want
		DELETE FROM #tempActiveMonths WHERE ADate NOT BETWEEN DATEADD(MM, (@NumberOfMonths * -1)+1, @CurrentDate) AND @CurrentDate

		PRINT @CurrentDate;

		SET @PreviousMonth = DATEADD(MM, -1, @CurrentDate)
		DECLARE @PreviousMonthID as varchar(50)
		SELECT @PreviousMonthID = ActiveMonthYearID FROM General.ActiveMonthYear WHERE ModID = 4 AND AYear = DATEPART(yyyy, @PreviousMonth) AND AMonth = DATEPART(MM, @PreviousMonth)
		
		-- *********** End of getting ActiveMonthYearID of N Months ***********

		--- !!! Check whether all deliveries from Blocks on this month have ABW for Last Month !!! ---
		SELECT d.Name as Supplier, c.Block 
		INTO #tmpBlocksMissingABW
		FROM
		(
		SELECT DISTINCT SupplierCustID, FieldBlockSetupID FROM Weighbridge.WBWeighingInOut a 
		INNER JOIN Weighbridge.WBWeighingBlockDetail b on a.WeighingID = b.WeighingID
		WHERE ActiveMonthYearID = @ActiveMonthYearID
		) a 
		LEFT JOIN Weighbridge.AverageBunchWeightBlock b
		ON a.SupplierCustID = b.SupplierCustID and a.FieldBlockSetupID = b.FieldBlockSetupID AND b.ActiveMonthYearID = @PreviousMonthID
		INNER JOIN Weighbridge.WBFieldBlockSetup c ON a.SupplierCustID = c.SupplierCustID AND a.FieldBlockSetupID = c.FieldBlockSetupID
		INNER JOIN Weighbridge.WBSupplier d ON c.SupplierCustID = d.SupplierCustID
		WHERE b.FieldBlockSetupID IS NULL

		--- !!! END of Checking previous months ABW existance compare to this months Blocks !!! ---
		DECLARE @MissingBlocks as int
		SELECT @MissingBlocks = Count(Block) FROM #tmpBlocksMissingABW

		IF @MissingBlocks > 0 
			BEGIN
				PRINT '--- Some blocks do not have ABW for Last Month --'
				SELECT * FROM #tmpBlocksMissingABW
			END
		ELSE
			BEGIN
				-- show empty table if all blocks have value for previous month
				SELECT * FROM #tmpBlocksMissingABW

				-- GET Tickets having deliveries from Single Block 
				--SELECT WeighingID, Count(FieldBlockSetupID) UniqueBlockCount
				--INTO #tmpSingleBlock
				--FROM 
				--(
				--	SELECT b.WeighingID, FieldBlockSetupID, COUNT(FieldBlockSetupID) Block 
				--	FROM Weighbridge.WBWeighingBlockDetail a
				--	INNER JOIN Weighbridge.WBWeighingInOut b on a.WeighingID = b.WeighingID
				--	WHERE ActiveMonthYearID = @ActiveMonthYearID
				--	GROUP BY b.WeighingID, FieldBlockSetupID
				--) tbl GROUP By WeighingID
				--Having Count(FieldBlockSetupID) = 1

				SELECT b.SupplierCustID, c.FieldBlockSetupID, a.WeighingID 
				INTO #tmpSingleBlock
				FROM (
					SELECT WeighingID, Count(FieldBlockSetupID) UniqueBlockCount
						FROM 
							(
								SELECT b.WeighingID, FieldBlockSetupID, COUNT(FieldBlockSetupID) Block 
								FROM Weighbridge.WBWeighingBlockDetail a
								INNER JOIN Weighbridge.WBWeighingInOut b on a.WeighingID = b.WeighingID
								WHERE ActiveMonthYearID = @ActiveMonthYearID
								GROUP BY b.WeighingID, FieldBlockSetupID
							) tbl GROUP By WeighingID
							Having Count(FieldBlockSetupID) = 1
					) a 
				INNER JOIN Weighbridge.WBWeighingInOut b ON a.WeighingID = b.WeighingID 
				INNER JOIN (
					SELECT DISTINCT FieldBlockSetupID, WeighingID FROM Weighbridge.WBWeighingBlockDetail 
				) c on b.WeighingID = c.WeighingID 


				DECLARE @SingleBlockDeliveries as int
				DECLARE @TotalDeliveries as int

				SELECT @SingleBlockDeliveries = Count(WeighingID) FROM #tmpSingleBlock
				SELECT @TotalDeliveries = Count(WeighingID) FROM Weighbridge.WBWeighingInOut WHERE ActiveMonthYearID = @ActiveMonthYearID
	
				-- END of getting Single block deliveries

				-- Do the calculation based on weighing details for Current Month 

				SELECT b.WeighingID, b.WBTicketNo, c.SupplierCustID, c.Block, c.FieldBlockSetupID, Qty, LooseFruit, IsNull(Ketek,0) Ketek, b.NetWeight, tblKetek.TotalKetek,
				--HABW, (HABW * Qty) as FFB_ABW,
				--CASE WHEN LooseFruit > 0 AND Qty = 0 AND Ketek = 0 THEN
				--	b.NetWeight - LooseFruit
				--ELSE
				--	b.NetWeight
				--END as WeightTBAllocated,
				--CASE WHEN LooseFruit > 0 AND Qty = 0 AND Ketek = 0 THEN
				--	LooseFruit
				--ELSE
				--	0
				--END as LooseFruitAllocated
				a.ABW as HABW, (a.ABW * Qty) as FFB_ABW,a.AllocatedWeight as WeightTBAllocated,a.LooseFruit as LooseFruitAllocated
				INTO #tempABW
				FROM [Weighbridge].[WBWeighingBlockDetail] a
				INNER JOIN [Weighbridge].[WBWeighingInOut] b on a.WeighingID = b.WeighingID
				INNER JOIN [Weighbridge].[WBFieldBlockSetup] c on a.FieldBlockSetupID = c.FieldBlockSetupID
				INNER JOIN 
					(
					SELECT ISNULL(SUM(Ketek),0) as TotalKetek , b.WBTicketNo, b.ActiveMonthYearID FROM [Weighbridge].[WBWeighingBlockDetail] a
					INNER JOIN [Weighbridge].[WBWeighingInOut] b on a.WeighingID = b.WeighingID
					GROUP BY WBTicketNo, ActiveMonthYearID
					) as tblKetek on b.WBTicketNo = tblKetek.WBTicketNo AND b.ActiveMonthYearID = tblKetek.ActiveMonthYearID
				INNER JOIN
					(
					SELECT FieldBlockSetupID, CalculatedABW as HABW 
					FROM Weighbridge.AverageBunchWeightBlock
					--WHERE ActiveMonthYearID IN (SELECT ActiveMonthYearID FROM #tempActiveMonths )
					WHERE ActiveMonthYearID = @PreviousMonthID
					--GROUP BY FieldBlockSetupID
					) as tblABW on a.FieldBlockSetupID = tblABW.FieldBlockSetupID
				WHERE b.ActiveMonthYearID = @ActiveMonthYearID	
					--AND b.WeighingID IN (SELECT WeighingID FROM #tmpSingleBlock)
		
				-- End of calculating ABW for current month

				-- if wanted to process the ABW-- delete existing record and insert new 
				IF @CalculateOnly = 0
					BEGIN
						-- Delete existing records for current Month
						DELETE FROM Weighbridge.AverageBunchWeightCalculated WHERE ActiveMonthYearID = @ActiveMonthYearID
						DELETE FROM Weighbridge.AverageBunchWeightBlock WHERE ActiveMonthYearID = @ActiveMonthYearID

						-- ADD new records
						PRINT '-- Adding Calculated ABW for current month --'
						INSERT INTO Weighbridge.AverageBunchWeightCalculated
							(EstateID, SupplierCustID, FieldBlockSetupID, ActiveMonthYearID, Bunches, WeightAllocated, LooseFruitAllocated, CalculatedABW, ModifiedBy)
							SELECT @EstateID, SupplierCustID, FieldBlockSetupID, @ActiveMonthYearID, Qty, WeightTBAllocated, LooseFruitAllocated, ISNULL((NULLIF((Ketek + FFB_ABW),0)/NULLIF(Qty,0)),0), @ModifiedBy FROM #tempABW
				
				
						-- add single deliveries to ABW Blocks table
						PRINT '-- Adding Single Deliveries --'
						INSERT INTO Weighbridge.AverageBunchWeightBlock
						(SupplierCustID, FieldBlockSetupID, ActiveMonthYearID, EstateID, Bunches, WeightAllocated, CalculatedABW, TotalMonths, CalculatedMethod, ModifiedBy )
						SELECT SupplierCustID, FieldBlockSetupID, @ActiveMonthYearID, @EstateID, SUM(ISNULL(Bunches,0)), SUM(ISNULL(WeightAllocated,0)), SUM((ISNULL(WeightAllocated, 0)) / NULLIF(ISNULL(Bunches,0),0)), @NumberOfMonths, 'SD', @ModifiedBy 
						FROM 
						(
							SELECT SupplierCustID, FieldBlockSetupID, SUM(Bunches) as Bunches, SUM(WeightAllocated) as WeightAllocated
							FROM (
								SELECT SupplierCustID, FieldBlockSetupID, SUM(ISNULL(Qty,0)) as Bunches, ISNULL(WeightTBAllocated,0) as WeightAllocated 
								FROM #tempABW WHERE WeighingID IN (SELECT WeighingID FROM #tmpSingleBlock) 
								GROUP BY SupplierCustID, FieldBlockSetupID, WeightTBAllocated
							) tmpTbl GROUP BY SupplierCustID, FieldBlockSetupID
							UNION ALL 
							
							SELECT a.SupplierCustID, a.FieldBlockSetupID, SUM(ISNULL(Bunches,0)) as Bunches, SUM(ISNULL(WeightAllocated,0)) as WeightAllocated
							FROM Weighbridge.AverageBunchWeightBlock a
							INNER JOIN 
								(SELECT Distinct SupplierCustID, FieldBlockSetupID FROM #tmpSingleBlock) b ON a.SupplierCustID = b.SupplierCustID AND a.FieldBlockSetupID = b.FieldBlockSetupID
								WHERE ActiveMonthYearID IN (SELECT ActiveMonthYearID FROM #tempActiveMonths)
								GROUP BY a.SupplierCustID, a.FieldBlockSetupID
						) as tblAll GROUP BY SupplierCustID, FieldBlockSetupID

						
						-- delete single deliveries
						PRINT '-- Delete Single Deliveries from Temp Table --'
						--DELETE FROM #tempABW WHERE WeighingID IN (SELECT WeighingID FROM #tmpSingleBlock) 
						DELETE #tempABW FROM #tempABW a 
						INNER JOIN Weighbridge.AverageBunchWeightBlock b ON a.SupplierCustID = b.SupplierCustID AND a.FieldBlockSetupID = b.FieldBlockSetupID 
						WHERE b.ActiveMonthYearID = @ActiveMonthYearID

						Declare @SimilarBlockCount int
						Set @SimilarBlockCount = 1

						-- If there is no single block delivery in current month, Get HABW from Similar Blocks
						While @SimilarBlockCount <= 3 -- There might be maximum 3 similar blocks, can increase this value if there are more similar blocks
						Begin
							-- similar block N
							PRINT '-- Checking for Similar Blocks ' + CAST(@SimilarBlockCount as varchar(3)) + ' --'
							INSERT INTO Weighbridge.AverageBunchWeightBlock
							(SupplierCustID, FieldBlockSetupID, ActiveMonthYearID, EstateID, Bunches, WeightAllocated, CalculatedABW, TotalMonths, CalculatedMethod, ModifiedBy )
							SELECT a.SupplierCustID, a.FieldBlockSetupID, @ActiveMonthYearID, @EstateID, SUM(ISNULL(c.Bunches,0)) as Bunches, ISNULL(c.WeightAllocated,0) as WeightAllocated, ISNULL(c.WeightAllocated, 0) / NULLIF(ISNULL(c.Bunches, 0),0), @NumberOfMonths, 'S'+CAST(@SimilarBlockCount as varchar(3)), @ModifiedBy
							FROM 
							(
								SELECT SupplierCustID, FieldBlockSetupID, SUM(Bunches) as Bunches, SUM(WeightAllocated) as WeightAllocated 
								FROM
								(
									SELECT SupplierCustID, FieldBlockSetupID, SUM(ISNULL(Qty,0)) as Bunches, ISNULL(WeightTBAllocated,0) as WeightAllocated 
									FROM #tempABW 
									--WHERE WeighingID IN (SELECT WeighingID FROM #tmpSingleBlock)
									GROUP BY SupplierCustID, FieldBlockSetupID, WeightTBAllocated
								) tblTemp GROUP BY SupplierCustID, FieldBlockSetupID
							) a
							INNER JOIN Weighbridge.WBSimilarBlock b on a.FieldBlockSetupID = b.OriginBlockSetupID AND b.MatchingSequence = @SimilarBlockCount
							INNER JOIN Weighbridge.AverageBunchWeightBlock c on c.SupplierCustID = b.SupplierCustID AND c.FieldBlockSetupID = b.SimilarBlockSetupID AND c.ActiveMonthYearID = @ActiveMonthYearID
							GROUP BY a.SupplierCustID, a.FieldBlockSetupID, a.WeightAllocated, c.WeightAllocated, c.Bunches
							
							-- delete similar blocks N
							PRINT '-- Delete Similar Blocks ' + CAST(@SimilarBlockCount as varchar(3)) + ' from Temp Table --'
							DELETE #tempABW FROM #tempABW a 
							INNER JOIN Weighbridge.AverageBunchWeightBlock b ON a.SupplierCustID = b.SupplierCustID AND a.FieldBlockSetupID = b.FieldBlockSetupID 
							WHERE b.ActiveMonthYearID = @ActiveMonthYearID

							Set @SimilarBlockCount = @SimilarBlockCount + 1
						End -- end of While Loop
				
						-- get previous months HABW for remaining Blocks
						PRINT '-- Getting Previous month"s HABW for remaining blocks --'
						INSERT INTO Weighbridge.AverageBunchWeightBlock
							(SupplierCustID, FieldBlockSetupID, ActiveMonthYearID, EstateID, Bunches, WeightAllocated, CalculatedABW, TotalMonths, CalculatedMethod, ModifiedBy )
						SELECT b.SupplierCustID, b.FieldBlockSetupID, @ActiveMonthYearID, @EstateID, SUM(b.Bunches), SUM(b.WeightAllocated), SUM(ISNULL(NULLIF(b.WeightAllocated,0)/NULLIF(b.Bunches,0),0)), '1', 'PM', @ModifiedBy
						FROM Weighbridge.AverageBunchWeightBlock a
						INNER JOIN (
							SELECT SupplierCustID, FieldBlockSetupID, SUM(Bunches) as Bunches, SUM(WeightAllocated) as WeightAllocated 
							FROM
							(
								SELECT SupplierCustID, FieldBlockSetupID, SUM(ISNULL(Qty,0)) as Bunches, SUm(ISNULL(WeightTBAllocated,0)) as WeightAllocated 
								FROM #tempABW 
								GROUP BY SupplierCustID, FieldBlockSetupID
							) tblTemp GROUP BY SupplierCustID, FieldBlockSetupID
						) b
						ON a.SupplierCustID = b.SupplierCustID AND a.FieldBlockSetupID = b.FieldBlockSetupID 
							AND a.ActiveMonthYearID = @PreviousMonthID
						GROUP BY b.SupplierCustID, b.FieldBlockSetupID

						-- delete previous months data from temp table
						PRINT '-- Deleting previous months data from temp table --'
						DELETE #tempABW FROM #tempABW a 
						INNER JOIN Weighbridge.AverageBunchWeightBlock b ON a.SupplierCustID = b.SupplierCustID AND a.FieldBlockSetupID = b.FieldBlockSetupID 
						WHERE b.ActiveMonthYearID = @ActiveMonthYearID

						-- Blocks that does not have HABW
						--SELECT DISTINCT SupplierCustID, FieldBlockSetupID FROM #tempABW

					END -- end of Processing, NOT Calculate ONLY
				Else
					-- if CALCULATE Only
					BEGIN
						-- show total deliveries and single block deliveries
						SELECT @TotalDeliveries as TotalDeliveries, @SingleBlockDeliveries as SingleBlockDeliveries;

						-- do the final calculation based on the values in temp Table
						SELECT a.WBTicketNo, b.Name as Supplier, Block, FieldBlockSetupID, HABW, Qty, LooseFruit, Ketek, FFB_ABW, TotalFFB_ABW, (Ketek + FFB_ABW) as TotalFFB_Ketek,
						NetWeight, TotalKetek, WeightTBAllocated, LooseFruitAllocated, ISNULL((NULLIF((Ketek + FFB_ABW),0)/NULLIF(Qty,0)),0) as CalculatedABW
						FROM #tempABW a
						INNER JOIN Weighbridge.WBSupplier b on a.SupplierCustID = b.SupplierCustID
						INNER JOIN 
							(
							SELECT WBTicketNo, SUM(FFB_ABW) TotalFFB_ABW FROM #tempABW
							GROUP By WBTicketNo
							) as tblTotalFFB_ABW on a.WBTicketNo = tblTotalFFB_ABW.WBTicketNo
					END
				
				-- drop temp tables
				DROP TABLE #tempABW
				DROP TABLE #tmpSingleBlock
				
			END -- end of Missing blocks validation

		DROP TABLE #tmpBlocksMissingABW
		DROP TABLE #tempActiveMonths

		--add missing fields so that there is no more missed block avg bunch weight errors
		
	insert into Weighbridge.AverageBunchWeightBlock(SupplierCustID,FieldBlockSetupID,ActiveMonthYearID,EstateID,Bunches,WeightAllocated,CalculatedABW,TotalMonths,CalculatedMethod,ModifiedBy,ModifiedDate)
	select a.SupplierCustID,a.FieldBlockSetupID,@ActiveMonthYearID,a.EstateID,1,a.CalculatedABW,a.CalculatedABW,a.TotalMonths,'SD',@ModifiedBy,GETDATE() from 
	(select * from Weighbridge.AverageBunchWeightBlock where ActiveMonthYearID = @PreviousMonthID) as a
	left join
	(select * from Weighbridge.AverageBunchWeightBlock where ActiveMonthYearID = @ActiveMonthYearID) as b on a.FieldBlockSetupID = b.FieldBlockSetupID  and a.SupplierCustID = b.SupplierCustID 
	where b.FieldBlockSetupID is null
	
END TRY
BEGIN CATCH

	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState    INT;

    SELECT @ErrorMessage  = ERROR_MESSAGE() ,
		@ErrorSeverity = ERROR_SEVERITY(),
        @ErrorState    = ERROR_STATE();

	RAISERROR (@ErrorMessage, -- Message text.
		@ErrorSeverity,           -- Severity.
        @ErrorState               -- State.
        );

END CATCH;

--------------------------------------------------
