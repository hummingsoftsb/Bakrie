/****** Object:  StoredProcedure [Checkroll].[CRDistributionActivitySummaryDaily]    Script Date: 8/10/2015 3:00:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================
--
-- Author      : < Dadang Adi Hendradi            >
-- Create date : < Senin, 09 Nov 2009, 11:20      >
-- Modified    : Tuesday, 10 Nov 2009, 19:21
-- Modified    : Wednesday, 11 Nov 2009, 13:21 -> Adding counting for DistbOTValue for GangMasterID and EmpID
-- Modified    : Sabtu, 26 Dec 2009, 21:44 Finishing for GangMasterID condition
-- Modified    : Ahad, 27 Dec 2009, 12:37 Finishing for EmpID condition
-- Description : < CRDistributionActivitySummary  >
--
-- ==============================================
ALTER PROCEDURE [Checkroll].[CRDistributionActivitySummaryDaily]

	@EstateID nvarchar(50),
	@ActiveMonthYearID nvarchar(50),
	@CreatedBy nvarchar(50),
	@DistDate nvarchar(50)

AS
DECLARE @EstateCode nvarchar(50);
DECLARE @GangMasterID nvarchar(50);
DECLARE @EmpID nvarchar(50)
DECLARE @Category nvarchar(50)
DECLARE @COAID nvarchar(50)

DECLARE @DistbMandays numeric(18,2)		 -- Sum(Mandays)
DECLARE @DistbMandayValue numeric(18,2)  -- BasicRate * Sum(Mandays)
DECLARE @DistbOT numeric(18,2)
DECLARE @DistbOTValue numeric(18,2)

DECLARE @CreatedOn datetime
DECLARE	@ModifiedBy nvarchar(50)
DECLARE @ModifiedOn datetime

DECLARE @count int
DECLARE @SumMandays numeric(18,2)

DECLARE @Year int
DECLARE @Month int

DECLARE @ActivitySummaryID nvarchar(50);
DECLARE @BasicRate numeric(18,2);
DECLARE @TotalOT numeric(18,2);
DECLARE @TotalOTValue numeric(18,2);

DECLARE @TransDate datetime;   -- Sabtu, 26 Dec 2009, 21:53
DECLARE @Ha numeric(18,2); -- Sabtu, 26 Dec 2009, 21:43
DECLARE @DIVID nvarchar(50);
DECLARE @YOPID nvarchar(50);
DECLARE @BlockID nvarchar(50);

	--SET @ActiveMonthYearID = '01R10';
	--SET @EstateID = 'M1';

		
	SELECT @EstateCode = EstateCode
	FROM
		General.Estate
	WHERE
		EstateID = @EstateID;

	SET @ModifiedBy = @CreatedBy
	SET @CreatedOn = GETDATE()
	SET @ModifiedOn = GETDATE()

	-- DailyActivityDistribution Cursor
	DECLARE DAD_Cursor CURSOR FOR
	SELECT
		
		C_DAD.GangMasterID, 
		C_DAD.EmpID,
		C_DAD.COAID,
		C_DAD.DistbDate,
		C_DAD.DivID,
		C_DAD.YOPID,
		C_DAD.BlockID
		
	FROM
		Checkroll.DailyActivityDistribution AS C_DAD
		WHERE
		C_DAD.EstateID = @EstateID AND
		C_DAD.ActiveMonthYearID = @ActiveMonthYearID AND
		C_DAD.DistbDate = CONVERT(datetime, @DistDate, 103)

            
    OPEN DAD_Cursor
    FETCH NEXT FROM DAD_Cursor
    INTO @GangMasterID, @EmpID, @COAID, @TransDate, @DivID, @YOPID, @BlockID
    WHILE @@FETCH_STATUS = 0
    BEGIN
    
		SET @DistbMandays = 0
		SET @DistbOT = 0
		SET @Category = NULL
		SET @Ha = 0
    
		IF @EmpID IS NULL
		BEGIN
			-- Berarti ini Team, dia punya GangMasterID
			
			
			SELECT 
				@DistbMandays = SUM(ISNULL(Mandays, 0)), 
				@DistbOT = SUM(ISNULL(OT, 0)),
				@Category = C_GM.Category
				--,@Ha = SUM(ISNULL(Ha, 0)) -- Sabtu, 26 Dec 2009, 22:19
			FROM
				Checkroll.DailyActivityDistribution AS C_DAD
				INNER JOIN Checkroll.GangMaster AS C_GM on C_DAD.GangMasterID = C_GM.GangMasterID
			WHERE
				C_DAD.EstateID = @EstateID AND
				C_DAD.ActiveMonthYearID = @ActiveMonthYearID AND
				C_DAD.COAID = @COAID
				AND C_DAD.GangMasterID = @GangMasterID
				AND C_DAD.DistbDate = @TransDate
			GROUP BY
				C_DAD.COAID, BlockID, C_GM.Category
				;
			
			-- GET BasicRate AVG FOR TEAM 
			select  @BasicRate = Sum(IsNull(checkroll.GetEmployeeDailyRate(Empid),0)) / ISnull(Count(EmpID),0) 
			from   checkroll.DailyGangEmployeeSetup where GangMasterID = @GangMasterID and ddate= @TransDate

			-- Hitung DistbMandayValue	
			SET @DistbMandayValue = @BasicRate * @DistbMandays

			-- Hitung TotalOTValue
			SET @TotalOT = 0
			SET @TotalOTValue = 0
			SET @DistbOTValue = 0
			
			SELECT
				
				@TotalOT = ISNULL(SUM( ISNULL(C_DA.TotalOT,0) ), 0),
				@TotalOTValue = ISNULL(SUM( ISNULL(C_DA.TotalOTValue, 0) ), 0)
				
			FROM
				Checkroll.DailyAttendance AS C_DA
				INNER JOIN Checkroll.DailyTeamActivity AS C_DTA on C_DA.DailyTeamActivityID = C_DTA.DailyTeamActivityID
			WHERE
				C_DA.EstateID = @EstateID AND
				C_DA.ActiveMonthYearID = @ActiveMonthYearID AND
				C_DTA.GangMasterID = @GangMasterID
			Group by C_DA.DailyTeamActivityID
			
			IF @TotalOT <> 0
			BEGIN
				SET @DistbOTValue = (@DistbOT / @TotalOT) * @TotalOTValue
			END
			
			IF EXISTS(SELECT ActivitySummarID FROM Checkroll.DistributionActivitySummary
				WHERE
				EstateID = @EstateID AND
				ActiveMonthYearID = @ActiveMonthYearID AND
				COAID = @COAID AND
				Category = @Category AND
				TransDate = @TransDate -- Selasa, 22 Dec 2009, 21:33
				AND BlockID = @BlockID
				AND YOPID = @YOPID
				AND DIVID = @DIVID
				)
			BEGIN
				
				UPDATE Checkroll.DistributionActivitySummary SET
					DistbMandays = @DistbMandays,
					DistbMandayValue = @DistbMandayValue,
					DistbOT = @DistbOT,
					DistbOTValue = @DistbOTValue
					--,Ha = @Ha,
					,DIVID = @DIVID
					,YOPID = @YOPID
					,BlockID = @BlockID
				WHERE
					EstateID = @EstateID AND
					ActiveMonthYearID = @ActiveMonthYearID AND
					COAID = @COAID AND
					Category = @Category AND
					TransDate = @TransDate
					AND BlockID = @BlockID
					AND YOPID = @YOPID
					AND DIVID = @DIVID
				
				
			END -- Jika sudah ada record nya dan BlockID IS NOT NULL, YOPID IS NOT NULL, DivID IS NOT NULL
			ELSE
			IF EXISTS(SELECT ActivitySummarID FROM Checkroll.DistributionActivitySummary
				WHERE
				EstateID = @EstateID AND
				ActiveMonthYearID = @ActiveMonthYearID AND
				COAID = @COAID AND
				Category = @Category AND
				TransDate = @TransDate -- Selasa, 22 Dec 2009, 21:33
				AND BlockID IS NULL
				AND YOPID IS NULL
				AND DIVID IS NULL
				)
			BEGIN
				
				UPDATE Checkroll.DistributionActivitySummary SET
					DistbMandays = @DistbMandays,
					DistbMandayValue = @DistbMandayValue,
					DistbOT = @DistbOT,
					DistbOTValue = @DistbOTValue
					--,Ha = @Ha
					,DIVID = @DIVID
					,YOPID = @YOPID
					,BlockID = @BlockID
				WHERE
					EstateID = @EstateID AND
					ActiveMonthYearID = @ActiveMonthYearID AND
					COAID = @COAID AND
					Category = @Category AND
					TransDate = @TransDate
					AND BlockID IS NULL
					AND YOPID IS NULL
					AND DIVID IS NULL
				
				
			END -- Jika sudah ada record nya dan BlockID IS NULL, YOPID IS NULL, DivID IS NULL
						
			ELSE
			BEGIN
				-- Jika belum ada record nya
				SELECT @count = ISNULL(Max(Id), 0) + 1
				FROM
				Checkroll.DistributionActivitySummary
				
				SET @ActivitySummaryID = @EstateCode + 'R' + CONVERT(NVARCHAR, @count)
				
				INSERT INTO Checkroll.DistributionActivitySummary
				(
				ActivitySummarID,
				ActiveMonthYearID,
				TransDate,
				EstateID,
				Category,
				COAID,
				DistbMandays,
				DistbMandayValue,
				DistbOT,
				DistbOTValue,
				DIVID,
				YOPID,
				BlockID,
				CreatedBy,
				CreatedOn,
				ModifiedBy,
				ModifiedOn
				)
				VALUES
				(
				@ActivitySummaryID,
				@ActiveMonthYearID,
				@TransDate,
				@EstateID,
				@Category,
				@COAID,
				@DistbMandays,
				@DistbMandayValue,
				@DistbOT,
				@DistbOTValue,
				@DIVID,
				@YOPID,
				@BlockID,
				@CreatedBy,
				@CreatedOn,
				@ModifiedBy,
				@ModifiedOn
				)
				
			END -- jika belum ada record

		END -- IF @EmpID IS NULL
		
		ELSE
		BEGIN
			-- Berarti ini bukan Team, dia punya EmpID
			SELECT 
				@DistbMandays = ISNULL(SUM(Mandays), 0), 
				@DistbOT = ISNULL(SUM(OT), 0),
				@Category = C_EMP.Category
				--,@Ha = SUM(ISNULL(Ha, 0)) -- Ahad, 27 Dec 2009, 12:23
			FROM
				Checkroll.DailyActivityDistribution AS C_DAD
				INNER JOIN Checkroll.CREmployee AS C_EMP on C_DAD.EmpID = C_EMP.EmpID
			WHERE
				C_DAD.EstateID = @EstateID AND
				C_DAD.ActiveMonthYearID = @ActiveMonthYearID AND
				C_DAD.COAID = @COAID
				AND C_DAD.EmpID = @EmpID
				AND C_DAD.DistbDate = @TransDate
			GROUP BY
				C_DAD.COAID, BlockID, C_EMP.Category
				;
				
			-- GET BasicRate
			Set  @BasicRate = Isnull(Checkroll.GetEmployeeDailyRate(@EmpID),0)
			
			-- Hitung DistbMandayValue	
			SET @DistbMandayValue = @BasicRate * @DistbMandays

			-- Hitung TotalOTValue
			SET @TotalOT = 0
			SET @TotalOTValue = 0
			SET @DistbOTValue = 0

			SELECT
				
				@TotalOT = ISNULL(SUM( ISNULL(C_DA.TotalOT,0) ), 0),
				@TotalOTValue = ISNULL(SUM( ISNULL(C_DA.TotalOTValue, 0) ), 0)
				
			FROM
				Checkroll.DailyAttendance AS C_DA
				--INNER JOIN Checkroll.DailyTeamActivity AS C_DTA on C_DA.DailyTeamActivityID = C_DTA.DailyTeamActivityID
			WHERE
				C_DA.EstateID = @EstateID AND
				C_DA.ActiveMonthYearID = @ActiveMonthYearID AND
				C_DA.EmpID = @EmpID
			Group by C_DA.EmpID
			
			IF @TotalOT <> 0
			BEGIN
				SET @DistbOTValue = (@DistbOT / @TotalOT) * @TotalOTValue
			END
			
			IF EXISTS(
				SELECT ActivitySummarID FROM Checkroll.DistributionActivitySummary
				WHERE
					EstateID = @EstateID AND
					ActiveMonthYearID = @ActiveMonthYearID AND
					COAID = @COAID AND
					Category = @Category AND
					TransDate = @TransDate
				)
			BEGIN
				
				UPDATE Checkroll.DistributionActivitySummary SET
					DistbMandays = @DistbMandays,
					DistbMandayValue = @DistbMandayValue,
					DistbOT = @DistbOT,
					DistbOTValue = @DistbOTValue,
					--Ha = @Ha,
					DIVID = @DIVID,
					YOPID = @YOPID,
					BlockID = @BlockID
				WHERE
					EstateID = @EstateID AND
					ActiveMonthYearID = @ActiveMonthYearID AND
					COAID = @COAID AND
					Category = @Category AND
					TransDate = @TransDate
					AND BlockID = @BlockID
					AND YOPID = @YOPID
					AND DIVID = @DIVID
				
				
			END -- Jika sudah ada record nya dan BlockID IS NOT NULL, YOPID IS NOT NULL, DivID IS NOT NULL
			ELSE
			IF EXISTS(SELECT ActivitySummarID FROM Checkroll.DistributionActivitySummary
				WHERE
				EstateID = @EstateID AND
				ActiveMonthYearID = @ActiveMonthYearID AND
				COAID = @COAID AND
				Category = @Category AND
				TransDate = @TransDate -- Selasa, 22 Dec 2009, 21:33
				AND BlockID IS NULL
				AND YOPID IS NULL
				AND DIVID IS NULL
				)
			BEGIN
				
				UPDATE Checkroll.DistributionActivitySummary SET
					DistbMandays = @DistbMandays,
					DistbMandayValue = @DistbMandayValue,
					DistbOT = @DistbOT,
					DistbOTValue = @DistbOTValue
					--,Ha = @Ha,
					,DIVID = @DIVID
					,YOPID = @YOPID
					,BlockID = @BlockID
				WHERE
					EstateID = @EstateID AND
					ActiveMonthYearID = @ActiveMonthYearID AND
					COAID = @COAID AND
					Category = @Category AND
					TransDate = @TransDate
					AND BlockID IS NULL
					AND YOPID IS NULL
					AND DIVID IS NULL
				
				
			END -- Jika sudah ada record nya dan BlockID IS NULL, YOPID IS NULL, DivID IS NULL
			ELSE

			BEGIN
				-- Jika belum ada record nya
				SELECT @count = ISNULL(Max(Id), 0) + 1
				FROM
				Checkroll.DistributionActivitySummary
				
				SET @ActivitySummaryID = @EstateCode + 'R' + CONVERT(NVARCHAR, @count)
				
				INSERT INTO Checkroll.DistributionActivitySummary
				(
				ActivitySummarID,
				ActiveMonthYearID,
				TransDate,
				EstateID,
				Category,
				COAID,
				DistbMandays,
				DistbMandayValue,
				DistbOT,
				DistbOTValue,
				CreatedBy,
				CreatedOn,
				ModifiedBy,
				ModifiedOn
				)
				VALUES
				(
				@ActivitySummaryID,
				@ActiveMonthYearID,
				@TransDate,
				@EstateID,
				@Category,
				@COAID,
				@DistbMandays,
				@DistbMandayValue,
				@DistbOT,
				@DistbOTValue,
				@CreatedBy,
				@CreatedOn,
				@ModifiedBy,
				@ModifiedOn
				)
				
			END -- jika belum ada record
				
		END
				
		FETCH NEXT FROM DAD_Cursor
		INTO @GangMasterID, @EmpID, @COAID, @TransDate, @DivID, @YOPID, @BlockID
    END
    
	CLOSE DAD_Cursor
	DEALLOCATE DAD_Cursor
