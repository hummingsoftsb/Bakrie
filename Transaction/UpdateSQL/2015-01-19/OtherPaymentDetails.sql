
/****** Object:  StoredProcedure [Checkroll].[OtherPaymentDetails]    Script Date: 19/1/2015 4:12:29 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- SP Modified by Nazim on 02 October 2013 to speedup monthly processing (reduced processing time from 20 minutes to 3 seconds!!)

ALTER PROCEDURE [Checkroll].[OtherPaymentDetails]
@EstateId nvarchar(50),
@ActiveMonthYearID nvarchar(50),
@Createdby nvarchar(50)
AS


Delete from Checkroll .OtherPaymentDetail where EstateID =@EstateId and ActiveMonthYearID =@ActiveMonthYearID 


BEGIN
	IF EXISTS(SELECT * FROM tempdb.dbo.sysobjects WHERE ID = OBJECT_ID(N'tempdb.dbo.#temp'))
	BEGIN
		DROP TABLE #temp
	END
	
	SELECT GangMasterID, EmpID, ISNULL(SUM(TotalRoundUP),0)-  ISNULL (SUM(TotalNett),0) as Roundvalue
	INTO #temp
	FROM Checkroll.Salary 
	WHERE ActiveMonthYearID = @ActiveMonthYearID AND GangMasterID IS NOT NULL
	GROUP BY  GangMasterID, EmpID, ActiveMonthYearID

	DECLARE @ToDT datetime

	select @ToDT = ToDT from General.ActiveMonthYear a 
	inner join General.FiscalYear b on a.AYear = b.FYear and a.AMonth = b.Period
	where ActiveMonthYearID = @ActiveMonthYearID
	
	DECLARE @Estate varchar(50)
	DECLARE @ActiveMonth varchar(50)
	DECLARE @GangMaster varchar(50)
	DECLARE @Emp varchar(50)
	DECLARE @Holiday Int
	DECLARE @HolidayRate Numeric(18,2)
	DECLARE @Sunday Int
	DECLARE @SundayRate Numeric(18,2)
	DECLARE @Rainday Int
	DECLARE @RaindayRate Numeric(18,2)
	DECLARE @Leaveday Int
	DECLARE @LeavedayRate Numeric(18,2)
	DECLARE @Sickday Int
	DECLARE @SickdayRate Numeric(18,2)
	DECLARE @Adjday Int
	DECLARE @AdjdayRate Numeric(18,2)
	DECLARE @Totalday Int
	DECLARE @Totaldayvalue Numeric(18,2)
	DECLARE @Roundupvalue Numeric(18,2)
	
	
	DECLARE OtherPayment_Cursor CURSOR READ_ONLY FOR
	
	
	--FETCH NEXT FROM OtherPayment_Cursor INTO @Estate,@ActiveMonth,@GangMaster, @Emp,@Holiday,@HolidayRate,@Sunday,@SundayRate,@Rainday,@RaindayRate,@Leaveday,@LeavedayRate,@Sickday,@SickdayRate,@Adjday,@AdjdayRate,@Totalday,@Totaldayvalue,@Roundupvalue
	SELECT DISTINCT T2 .EstateID , T2 .ActiveMonthYearID ,T2 .GangMasterID,  T2 . EmpID	,T2 . HOLIDAY	, T2 .HOLIDAYRATE, T2 .SUNDAY ,T2 . SUNDAYRATE	,T2 .RAIN ,T2 .RAINDAYRATE	,T2 .LEAVE	, T2 .LEAVEDAYRATE ,T2 .SICK	,T2 . SICKDAYRATE ,T2 .AdjustmentDay , T2 .AdjustmentDayRate ,T2 .TOTALDAY 	,T2 .Totaldayvalue    from

		(SELECT
			EstateID , ActiveMonthYearID , GangMasterID,  EmpID	, HOLIDAY	, HOLIDAYRATE, SUNDAY , SUNDAYRATE	,RAIN ,RAINDAYRATE	,LEAVE	, LEAVEDAYRATE ,SICK	, SICKDAYRATE ,AdjustmentDay = Checkroll.CRFnGetAdjustmentDay(OP.EstateID, 
			OP.AMonth, OP.AYear)	, AdjustmentDayRate = (Checkroll.CRFnGetAdjustmentDay(OP.EstateID, 
			OP.AMonth, OP.AYear) * BasicRate)	,TOTALDAY 	,Totaldayvalue,CreatedBy=@Createdby ,CreatedOn=GetDate(),Modifiedby=@Createdby ,ModifiedOn=GETDATE()
		
		FROM
			(
			SELECT
				C_EMP.EmpID ,HOLIDAY = ISNULL(C_ASUM.L0 , 0) + ISNULL(C_ASUM.L1, 0)+ ISNULL(C_ASUM.JL , 0), 
				HOLIDAYRATE = ((ISNULL(C_ASUM.L0 , 0) + ISNULL(C_ASUM.L1, 0)+ ISNULL(C_ASUM.JL , 0)) * C_RS.BasicRate)
				,SUNDAY = ISNULL(C_ASUM.M0, 0) + ISNULL(C_ASUM.M1, 0)
				,SUNDAYRATE=((ISNULL(C_ASUM.M0, 0) + ISNULL(C_ASUM.M1, 0))*C_RS.BasicRate)
				,RAIN = ISNULL(C_ASUM.H1, 0)
				,RAINDAYRATE=(ISNULL(C_ASUM.H1, 0)* C_RS.BasicRate)
				,LEAVE = ISNULL(C_ASUM.CB, 0) + ISNULL(C_ASUM.CH, 0) + ISNULL(C_ASUM.CT, 0) + ISNULL(C_ASUM.I1, 0) + ISNULL(C_ASUM.I2, 0)
				,LEAVEDAYRATE=((ISNULL(C_ASUM.CB, 0) + ISNULL(C_ASUM.CH, 0) + ISNULL(C_ASUM.CT, 0) + ISNULL(C_ASUM.I1, 0) + ISNULL(C_ASUM.I2, 0))* C_RS.BasicRate)
				,SICK = ISNULL(C_ASUM.S1, 0) + ISNULL(C_ASUM.S2, 0) + ISNULL(C_ASUM.S3, 0) + ISNULL(C_ASUM.S4, 0) + ISNULL(C_ASUM.CD, 0)
				,SICKDAYRATE=((ISNULL(C_ASUM.S1, 0) + ISNULL(C_ASUM.S2, 0) + ISNULL(C_ASUM.S3, 0) + ISNULL(C_ASUM.S4, 0) + ISNULL(C_ASUM.CD, 0))* C_RS.BasicRate)
				,TOTALDAY = ISNULL(C_ASUM.M0, 0) + ISNULL(C_ASUM.M1, 0) +
							ISNULL(C_ASUM.H1, 0) +
							ISNULL(C_ASUM.CB, 0) + ISNULL(C_ASUM.CD, 0) + ISNULL(C_ASUM.CH, 0) + ISNULL(C_ASUM.CT, 0) +
							ISNULL(C_ASUM.S1, 0) + ISNULL(C_ASUM.S2, 0) + ISNULL(C_ASUM.S3, 0) + ISNULL(C_ASUM.S4, 0)+
							ISNULL(C_ASUM.L0 , 0) + ISNULL(C_ASUM.L1, 0)+ ISNULL(C_ASUM.I1, 0) + ISNULL(C_ASUM.I2, 0)+ ISNULL(C_ASUM.JL, 0)
							+ Checkroll.CRFnGetAdjustmentDay(C_SAL.EstateID, G_AMY.AMonth, G_AMY.AYear)
				,TOTALDAYVALUE=((ISNULL(C_ASUM.M0, 0) + ISNULL(C_ASUM.M1, 0) +
							ISNULL(C_ASUM.H1, 0) +
							ISNULL(C_ASUM.CB, 0) + ISNULL(C_ASUM.CD, 0) + ISNULL(C_ASUM.CH, 0) + ISNULL(C_ASUM.CT, 0) +
							ISNULL(C_ASUM.S1, 0) + ISNULL(C_ASUM.S2, 0) + ISNULL(C_ASUM.S3, 0) + ISNULL(C_ASUM.S4, 0)+
							ISNULL(C_ASUM.L0 , 0) + ISNULL(C_ASUM.L1, 0)+ ISNULL(C_ASUM.I1, 0) + ISNULL(C_ASUM.I2, 0)+ ISNULL(C_ASUM.JL, 0)
							+ Checkroll.CRFnGetAdjustmentDay(C_SAL.EstateID, G_AMY.AMonth, G_AMY.AYear)) * C_RS.BasicRate)
				,OtherPaymentFromSalary = C_SAL.HarinLainUpah
		
				,C_SAL.EstateID
				,C_GM.GangMasterID 
				,C_RS.BasicRate
				,G_AMY.ActiveMonthYearID
				,G_AMY.AMonth
				,G_AMY.AYear
		
			FROM
				Checkroll.Salary AS C_SAL
				INNER JOIN Checkroll.CREmployee AS C_EMP ON C_SAL.EmpID = C_EMP.EmpID AND C_SAL.EstateID = C_EMP.EstateID
				LEFT JOIN Checkroll.GangEmployeeSetup AS C_GES ON C_SAL.EmpID = C_GES.EmpID
				LEFT JOIN Checkroll.GangMaster AS C_GM ON C_GES.GangMasterID = C_GM.GangMasterID
				INNER JOIN Checkroll.AttendanceSummary AS C_ASUM ON C_SAL.EmpID = C_ASUM.EmpID AND C_SAL.ActiveMonthYearID = C_ASUM.ActiveMonthYearID
				INNER JOIN General.Estate AS G_ESTATE ON C_SAL.EstateID = G_ESTATE.EstateID
				INNER JOIN General.ActiveMonthYear AS G_AMY ON C_SAL.ActiveMonthYearID = G_AMY.ActiveMonthYearID
				INNER JOIN Checkroll.RateSetup AS C_RS ON C_SAL.Category = C_RS.Category
		
				where C_SAL.EstateID = @EstateId AND C_SAL.ActiveMonthYearID = @ActiveMonthYearID 
				AND C_EMP.DOJ < @ToDT and C_SAL.GangMasterID IS NOT NULL
		
	   
			--select gangmasterid from Checkroll.Salary 
	
			) AS OP ) T2 
	
	
	
	OPEN OtherPayment_Cursor              
		FETCH NEXT FROM OtherPayment_Cursor INTO @Estate,@ActiveMonth,@GangMaster, @Emp,@Holiday,@HolidayRate,@Sunday,@SundayRate,@Rainday,@RaindayRate,@Leaveday,@LeavedayRate,@Sickday,@SickdayRate,@Adjday,@AdjdayRate,@Totalday,@Totaldayvalue
		WHILE @@FETCH_STATUS = 0         
		BEGIN
		SELECT @roundupvalue=Roundvalue  FROM #temp where GangMasterID=@GangMaster 
			--IF Not Exists(Select ID from Checkroll.OtherPaymentDetail where EstateID=@Estate and ActiveMonthYearID=@ActiveMonth and GangMasterID=@GangMaster and EmpID=@Emp and Holiday=@Holiday and HolidayRate=@HolidayRate and Sunday=@Sunday and SundayRate=@SundayRate and Rainday=@Rainday and RaindayRate=@RaindayRate and Leaveday=@Leaveday and LeavedayRate=@LeavedayRate and Sickday=@Sickday and SickdayRate=@SickdayRate and Adjday=@Adjday and AdjdayRate=@AdjdayRate and Totalday=@Totalday and Totaldayvalue=@Totaldayvalue and Roundupvalue=@Roundupvalue )
			--	BEGIN
					INSERT INTO Checkroll.OtherPaymentDetail (EstateID,ActiveMonthYearID,GangMasterID,EmpID,Holiday,HolidayRate,Sunday,SundayRate,Rainday,RaindayRate,Leaveday,LeavedayRate,Sickday,SickdayRate,Adjday,AdjdayRate,Totalday,Totaldayvalue,Roundupvalue,CreatedBy,CreatedOn,ModifiedBy,ModifiedOn ) 
					values(@Estate,@ActiveMonth,@GangMaster,@Emp,@Holiday,@HolidayRate,@Sunday,@SundayRate,@Rainday,@RaindayRate,@Leaveday,@LeavedayRate,@Sickday,@SickdayRate,@Adjday,@AdjdayRate,@Totalday,@Totaldayvalue,@Roundupvalue ,@Createdby,GETDATE(),@Createdby,GETDATE())
				--END
		FETCH NEXT FROM OtherPayment_Cursor INTO @Estate,@ActiveMonth,@GangMaster, @Emp,@Holiday,@HolidayRate,@Sunday,@SundayRate,@Rainday,@RaindayRate,@Leaveday,@LeavedayRate,@Sickday,@SickdayRate,@Adjday,@AdjdayRate,@Totalday,@Totaldayvalue
		END
	CLOSE OtherPayment_Cursor            
	DEALLOCATE OtherPayment_Cursor
	
	END
	
	
	
	
