USE [BSPMS_SR]
GO
/****** Object:  StoredProcedure [Checkroll].[InsertSalaryPremi]    Script Date: 12/6/2014 4:37:19 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


--========
-- Author : Dadang Adi Hendradi
-- update : Sabtu, 20 Mar 2010, 14:24
--
--=======

ALTER PROCEDURE [Checkroll].[InsertSalaryPremi]
	@EstateID nvarchar (50),
	@ActiveMonthYearID nvarchar (50),
	@User nvarchar (50)

AS

Declare @count int
Declare	@pTotRow Numeric(18,0)
Declare @EmpID as Nvarchar (50)
Declare @Premi AS Numeric(18,2)
Declare @DriverPremi AS Numeric(18,2)


BEGIN	

			
	SET XACT_ABORT ON
	DECLARE CR_DA CURSOR FOR 

	SELECT     
		C_DA.EmpID
		--,Premi = ISNULL(SUM(C_DR.PremiValue), 0) 
		--,DriverPremi = ISNULL(SUM(C_DA.DriverPremi),0)
		,Premi = SUM(ISNULL(C_DR.PremiValue, 0)) 
		,DriverPremi = SUM(ISNULL(C_DA.DriverPremi,0))
	FROM       
		Checkroll.DailyAttendance AS C_DA  
		-- INNER JOIN Checkroll.DailyReceiption AS C_DR ON C_DA.DailyReceiptionID = C_DR.DailyReceiptionID
		left outer JOIN Checkroll.DailyReceiption AS C_DR ON C_DA.DailyReceiptionID = C_DR.DailyReceiptionID
		-- SAI: add Daily Reception Rubber table 
	WHERE
		C_DA.EstateID = @EstateID
		AND C_DA.ActiveMonthYearID = @ActiveMonthYearID
	GROUP BY 
		C_DA.EmpID

	Open CR_DA;

	FETCH NEXT FROM CR_DA
	INTO @EmpID
		,@Premi
		,@DriverPremi
		
	WHILE @@FETCH_STATUS = 0 
	BEGIN
		
		
		IF EXISTS(
			SELECT C_SAL.EmpID 
			FROM 
				Checkroll.Salary AS C_SAL
			WHERE 
				C_SAL.EstateID = @EstateID 
				AND C_SAL.ActiveMonthYearID = @ActiveMonthYearID 
				AND  C_SAL.EmpID = @EmpID
			)
					
			BEGIN
				UPDATE Checkroll.Salary
				SET 
					Premi = @Premi,
					--TotalBruto = 
					--	ISNULL(TotalBasic, 0) + 
					--	ISNULL(TotalOTValue, 0) +
					--	@Premi + 
					--	ISNULL(Allowance, 0) + 
					--	ISNULL(MandorPremi, 0) + 
					--	ISNULL(KraniPremi, 0) + 
					--	@DriverPremi +
					--		(CASE WHEN Category ='KHT'
					--		THEN ISNULL(AttIncentiveRp ,0) 
					--		ELSE 0 END) + 
					--	ISNULL(K3Panen, 0)
					--,TotalDed = 
					--	ISNULL(DedAstek, 0) + 
					--	ISNULL(DedTaxEmployee, 0) 
					--	+ ISNULL(DedAdvance, 0) 
					--	+ ISNULL(DedOther, 0), 
					ModifiedBy = @User ,
					ModifiedOn = GETDATE()
				WHERE 
					EstateID = @EstateID 
					AND ActiveMonthYearID = @ActiveMonthYearID 
					AND EmpID = @EmpID  
			
			END;
			
					
		FETCH NEXT FROM CR_DA
 		INTO 
 			@EmpID
 			,@Premi
 			,@DriverPremi
  					
	END;
	
	CLOSE CR_DA;

	DEALLOCATE CR_DA

END








