
/****** Object:  StoredProcedure [Checkroll].[CRMoneyDenominationReport]    Script Date: 12/4/2016 8:49:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [Checkroll].[CRMoneyDenominationReport]

	@EstateID nvarchar(50),
	@ActiveMonthYearID nvarchar(50)
		
AS

DECLARE @angka numeric(18,2);
DECLARE @TotalRoundUP numeric(18,2);
DECLARE @EmpID nvarchar(50);
DECLARE @EmpName nvarchar(50);
DECLARE @Category nvarchar(50);
DECLARE @GangName nvarchar(50);

DECLARE @CategoryTmp nvarchar(50);
DECLARE @GangNameTmp nvarchar(50);

DECLARE @AMonth int;
DECLARE @AYear int;

DECLARE @Satuan100rb int;
DECLARE @Satuan50rb int;
DECLARE @Satuan20rb int;
DECLARE @Satuan10rb int;
DECLARE @Satuan5rb int;
DECLARE @Satuan1rb int;

DECLARE @HasilBagiDecimal100rb numeric(18,2);
DECLARE @HasilBagiDecimal50rb numeric(18,2);
DECLARE @HasilBagiDecimal20rb numeric(18,2);
DECLARE @HasilBagiDecimal10rb numeric(18,2);
DECLARE @HasilBagiDecimal5rb numeric(18,2);
DECLARE @HasilBagiDecimal1rb numeric(18,2);

DECLARE @HasilBagi100rb int;
DECLARE @HasilBagi50rb int;
DECLARE @HasilBagi20rb int;
DECLARE @HasilBagi10rb int;
DECLARE @HasilBagi5rb int;
DECLARE @HasilBagi1rb int;

DECLARE @Sisa100rb numeric(18,2);
DECLARE @Sisa50rb numeric(18,2);
DECLARE @Sisa20rb numeric(18,2);
DECLARE @Sisa10rb numeric(18,2);
DECLARE @Sisa5rb numeric(18,2);
DECLARE @Sisa1rb numeric(18,2);

DECLARE @JmlUang100rb numeric(18,2);
DECLARE @JmlUang50rb numeric(18,2);
DECLARE @JmlUang20rb numeric(18,2);
DECLARE @JmlUang10rb numeric(18,2);
DECLARE @JmlUang5rb numeric(18,2);
DECLARE @JmlUang1rb numeric(18,2);

DECLARE @JmlLembar100rb int;
DECLARE @JmlLembar50rb int;
DECLARE @JmlLembar20rb int;
DECLARE @JmlLembar10rb int;
DECLARE @JmlLembar5rb int;
DECLARE @JmlLembar1rb int;

SET @Satuan100rb = 100000;
SET @Satuan50rb = 50000;
SET @Satuan20rb = 20000;
SET @Satuan10rb = 10000;
SET @Satuan5rb = 5000;
SET @Satuan1rb = 1000;

DECLARE @SisaUang numeric(18,2);
DECLARE @Until datetime;
DECLARE @GangMasterBesarID nvarchar(50);

-- Selasa, 26 Jan 2010, 16:54
DECLARE @MD as table
(
	Category nvarchar(50),
	GangName nvarchar(50),
	Qty100rb int,
	Qty50rb int,
	Qty20rb int,
	Qty10rb int,
	Qty5rb int,
	Qty1rb int,
	EstateID nvarchar(50),
	ActiveMonthYearID nvarchar(50),
	AMonth int,
	AYear int,
	GangMasterBesarID nvarchar(50));


SET @JmlLembar100rb = 0;
SET @JmlLembar50rb = 0;
SET @JmlLembar20rb = 0;
SET @JmlLembar10rb = 0;
SET @JmlLembar5rb = 0;
SET @JmlLembar1rb = 0;

select @until=ToDT from General.ActiveMonthYear AM 
inner join General.FiscalYear FY on AM.AMonth = FY.Period and  AM.AYear = FY.FYear
where am.ActiveMonthYearID = @ActiveMonthYearId


DECLARE sal_cur CURSOR FOR

	
	SELECT 
	C_SALARY.EmpID
	,CEILING((ISNULL(INCOME, 0) - ISNULL(Deduction,0))/1000.0) * 1000 as TotalRoundUP
	,EmpName
	,C_SALARY.Category
	,ISNULL(GangName,'') as GangName
	,C_SALARY.EstateID
	,C_SALARY.ActiveMonthYearID
	,AMonth
	,AYear
	,C_GMBESAR.GangMasterBesarID
	FROM Checkroll.Salary C_SALARY 
	inner JOIN Checkroll.CREmployee AS C_EMP ON C_SALARY.EmpID = C_EMP.EmpID AND C_SALARY.EstateID = C_EMP.EstateID
	inner JOIN General.ActiveMonthYear AS G_AMY ON C_SALARY.ActiveMonthYearID = G_AMY.ActiveMonthYearID
	INNER JOIN  (
	select a.EmpID,AllowanceAmount as Income, isnull(deductionAmount,0) as Deduction,BankID,BankAccountNo
	from 
	(select Sum(Round(Amount,0)) as AllowanceAmount,EmpID from Checkroll.EmpAllowanceDeduction
	where month(EndDates) = Month(@until) and YEar(EndDates) = Year(@until) and type = 'A'  group by empid) as a
	LEFT join 
	(select Sum(Round(Amount,0)) as deductionAmount,EmpID from Checkroll.EmpAllowanceDeduction
	where month(EndDates) = Month(@until) and YEar(EndDates) = Year(@until) and type = 'D'  group by empid)as b
	on a.EmpID = b.EmpID
	inner join 
	(Select BankID,BankAccountNo,EmpID from Checkroll.CREmployee where BankID = 'M33' or BankID = '' or BankID is null) as c
		on a.EmpID = c.EmpID  
	
	) MonthlySalary ON C_SALARY.EmpID = MonthlySalary.EmpID 
	LEFT JOIN Checkroll.GangMaster AS C_GM ON C_SALARY.GangMasterID = C_GM.GangMasterID
	Left Join Checkroll.GangMasterBesar AS C_GMBESAR on C_Gm.GangMasterID = C_GMBESAR.GangMasterID
	WHERE C_SALARY.EstateID = @EstateID AND C_SALARY.ActiveMonthYearID = @ActiveMonthYearID
	ORDER BY C_SALARY.Category, C_GM.GangName
	
	OPEN sal_cur;

	FETCH NEXT FROM sal_cur
	INTO @EmpID, @TotalRoundUP, @EmpName, @Category, @GangName
		,@EstateID
		,@ActiveMonthYearID
		,@AMonth
		,@AYear,@gangmasterBEsarID

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		SET @HasilBagi100rb = 0;
		SET @HasilBagi50rb = 0;
		SET @HasilBagi20rb = 0;
		SET @HasilBagi10rb = 0;
		SET @HasilBagi5rb = 0;
		SET @HasilBagi1rb = 0;
		
		--SET @TotalRoundUP = 2337000;
		
		-- 100rb
		SET @HasilBagiDecimal100rb = @TotalRoundUP / @Satuan100rb;
		SET @HasilBagi100rb = FLOOR(@HasilBagiDecimal100rb);
		SET @Sisa100rb = @HasilBagiDecimal100rb - @HasilBagi100rb;
		
		SET @JmlUang100rb = @HasilBagi100rb * @Satuan100rb;
		
		SET @SisaUang = @Sisa100rb * @Satuan100rb;
		
		-- 50rb
		IF @HasilBagi100rb = 0
			IF @SisaUang / @Satuan50rb = 0
				SET @JmlUang50rb = 0;
			ELSE
			BEGIN
				SET @HasilBagiDecimal50rb = @SisaUang / @Satuan50rb;
				SET @HasilBagi50rb = FLOOR(@HasilBagiDecimal50rb);
				SET @Sisa50rb = @HasilBagiDecimal50rb - @HasilBagi50rb;
				
				SET @JmlUang50rb = @HasilBagi50rb * @Satuan50rb;
				
				SET @SisaUang = @Sisa50rb * @Satuan50rb;
			END
		ELSE
		BEGIN
			SET @HasilBagiDecimal50rb = @SisaUang / @Satuan50rb;
			SET @HasilBagi50rb = FLOOR(@HasilBagiDecimal50rb);
			SET @Sisa50rb = @HasilBagiDecimal50rb - @HasilBagi50rb;
			
			SET @JmlUang50rb = @HasilBagi50rb * @Satuan50rb;
			
			SET @SisaUang = @Sisa50rb * @Satuan50rb;
		END
		
		
		-- 20rb
		IF @HasilBagi50rb = 0
			IF @SisaUang / @Satuan20rb = 0
				SET @JmlUang20rb = 0;
			ELSE
			BEGIN
				SET @HasilBagiDecimal20rb = @SisaUang / @Satuan20rb;
				SET @HasilBagi20rb = FLOOR(@HasilBagiDecimal20rb);
				SET @Sisa20rb = @HasilBagiDecimal20rb - @HasilBagi20rb;
				
				SET @JmlUang20rb = @HasilBagi20rb * @Satuan20rb;
				
				SET @SisaUang = @Sisa20rb * @Satuan20rb;
			END
		ELSE
		BEGIN
			SET @HasilBagiDecimal20rb = @SisaUang / @Satuan20rb;
			SET @HasilBagi20rb = FLOOR(@HasilBagiDecimal20rb);
			SET @Sisa20rb = @HasilBagiDecimal20rb - @HasilBagi20rb;
			
			SET @JmlUang20rb = @HasilBagi20rb * @Satuan20rb;
			
			SET @SisaUang = @Sisa20rb * @Satuan20rb;
		END
		
		-- 10rb
		IF @HasilBagi20rb = 0
			IF @SisaUang / @Satuan10rb = 0
				SET @JmlUang10rb = 0;
			ELSE
			BEGIN
				SET @HasilBagiDecimal10rb = @SisaUang / @Satuan10rb;
				SET @HasilBagi10rb = FLOOR(@HasilBagiDecimal10rb);
				SET @Sisa10rb = @HasilBagiDecimal10rb - @HasilBagi10rb;
				
				SET @JmlUang10rb = @HasilBagi10rb * @Satuan10rb;
				
				SET @SisaUang = @Sisa10rb * @Satuan10rb;
			END
		ELSE
		BEGIN
			SET @HasilBagiDecimal10rb = @SisaUang / @Satuan10rb;
			SET @HasilBagi10rb = FLOOR(@HasilBagiDecimal10rb);
			SET @Sisa10rb = @HasilBagiDecimal10rb - @HasilBagi10rb;
			
			SET @JmlUang10rb = @HasilBagi10rb * @Satuan10rb;
			
			SET @SisaUang = @Sisa10rb * @Satuan10rb;
		END
		
		-- 5rb
		IF @HasilBagi10rb = 0
			IF @SisaUang / @Satuan5rb = 0
				SET @JmlUang5rb = 0;
			ELSE
			BEGIN
				SET @HasilBagiDecimal5rb = @SisaUang / @Satuan5rb;
				SET @HasilBagi5rb = FLOOR(@HasilBagiDecimal5rb);
				SET @Sisa5rb = @HasilBagiDecimal5rb - @HasilBagi5rb;
				
				SET @JmlUang5rb = @HasilBagi5rb * @Satuan5rb;
				
				SET @SisaUang = @Sisa5rb * @Satuan5rb;
			END
		ELSE
		BEGIN
			SET @HasilBagiDecimal5rb = @SisaUang / @Satuan5rb;
			SET @HasilBagi5rb = FLOOR(@HasilBagiDecimal5rb);
			SET @Sisa5rb = @HasilBagiDecimal5rb - @HasilBagi5rb;
			
			SET @JmlUang5rb = @HasilBagi5rb * @Satuan5rb;
			
			SET @SisaUang = @Sisa5rb * @Satuan5rb;
		END
		
		-- 1rb (seribu)
		IF @HasilBagi5rb = 0
			IF @SisaUang / @Satuan1rb = 0
				SET @JmlUang1rb = 0;
			ELSE
			BEGIN
				SET @HasilBagiDecimal1rb = @SisaUang / @Satuan1rb;
				SET @HasilBagi1rb = FLOOR(@HasilBagiDecimal1rb);
				SET @Sisa1rb = @HasilBagiDecimal1rb - @HasilBagi1rb;
				
				SET @JmlUang1rb = @HasilBagi1rb * @Satuan1rb;
				
			END
		ELSE
		BEGIN
			SET @HasilBagiDecimal1rb = @SisaUang / @Satuan1rb;
			SET @HasilBagi1rb = FLOOR(@HasilBagiDecimal1rb);
			SET @Sisa1rb = @HasilBagiDecimal1rb - @HasilBagi1rb;
			
			SET @JmlUang1rb = @HasilBagi1rb * @Satuan1rb;
			
		END

		IF (@CategoryTmp <> @Category OR @GangNameTmp <> @GangName)
			OR (@CategoryTmp IS NULL AND @GangNameTmp IS NULL)  
		BEGIN
			SET @CategoryTmp = @Category
			SET @GangNameTmp = @GangName
					
			SET @JmlLembar100rb = 0;
			SET @JmlLembar50rb = 0;
			SET @JmlLembar20rb = 0;
			SET @JmlLembar10rb = 0;
			SET @JmlLembar5rb = 0;
			SET @JmlLembar1rb = 0;
		END
		
		SET @JmlLembar100rb += @HasilBagi100rb;
		SET @JmlLembar50rb += @HasilBagi50rb;
		SET @JmlLembar20rb += @HasilBagi20rb;
		SET @JmlLembar10rb += @HasilBagi10rb;
		SET @JmlLembar5rb += @HasilBagi5rb;
		SET @JmlLembar1rb += @HasilBagi1rb;
			

		IF EXISTS(
			SELECT * FROM @MD 
			WHERE
				Category = @Category
				AND GangName = @GangName)
		BEGIN
			UPDATE @MD SET 
				Qty100rb = Qty100rb + @HasilBagi100rb
				,Qty50rb = Qty50rb + @HasilBagi50rb
				,Qty20rb = Qty20rb + @HasilBagi20rb
				,Qty10rb = Qty10rb + @HasilBagi10rb
				,Qty5rb = Qty5rb + @HasilBagi5rb
				,Qty1rb = Qty1rb + @HasilBagi1rb
			WHERE
				Category = @Category
				AND GangName = @GangName;
		END
		ELSE
		BEGIN
			INSERT INTO @MD (Category, GangName, Qty100rb, Qty50rb, Qty20rb, Qty10rb, Qty5rb, Qty1rb
				,EstateID
				,ActiveMonthYearID
				,AMonth
				,AYear,GangMasterBesarID)
			VALUES
			(@Category, @GangName, 
			@JmlLembar100rb, 
			@JmlLembar50rb,
			@JmlLembar20rb,
			@JmlLembar10rb,
			@JmlLembar5rb,
			@JmlLembar1rb
			,@EstateID
			,@ActiveMonthYearID
			,@AMonth
			,@AYear,@GangMasterBesarID);
		END
		
		FETCH NEXT FROM sal_cur
		INTO @EmpID, @TotalRoundUP, @EmpName, @Category, @GangName
		,@EstateID
		,@ActiveMonthYearID
		,@AMonth
		,@AYear,@GangMasterBEsarID

	END

	CLOSE sal_cur;
	DEALLOCATE sal_cur;

SELECT
	G_ESTATE.EstateName
	,MD.*
	, 
	(Qty100rb * 100000) + 
	(Qty50rb * 50000) + 
	(Qty20rb * 20000) +
	(Qty10rb * 10000) +
	(Qty5rb * 5000) +
	(Qty1rb * 1000) AS Value 
FROM 
	@MD AS MD
	INNER JOIN General.Estate AS G_ESTATE ON MD.EstateID = G_ESTATE.EstateID
	
DELETE FROM @MD
--SELECT SUM(
--	(Qty100rb * 100000) + 
--	(Qty50rb * 50000) + 
--	(Qty20rb * 20000) +
--	(Qty10rb * 10000) +
--	(Qty5rb * 5000) +
--	(Qty1rb * 1000))
--FROM @MD
