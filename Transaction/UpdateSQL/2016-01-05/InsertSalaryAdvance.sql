
/****** Object:  StoredProcedure [Checkroll].[InsertSalaryAdvance]    Script Date: 7/1/2016 1:51:49 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--
--
-- Modified : Senin, 23 Nov 2009, 18:03
--            Now Amount harus ambil dari PaidAmount
--
-- Modified by Dadang
-- Modified on : Sabtu, 13 Feb 2010, 20:11
--               Nilai advance yg dimasukan digaji adalah AdvancePaymentDet.Amount
-- Modified by Dadang
-- Kamis, 18 Mar 2010, 22:20
-- SELECT diakhir baris dihilangkan
--Modified by Stanley
-- Modified on 19-12-2011
--

ALTER PROCEDURE [Checkroll].[InsertSalaryAdvance]
@ActiveMonthYearId nvarchar (50),
@EstateId nvarchar (50),
@User nvarchar (50)

AS

Declare @count int
Declare	@pTotRow Numeric(18,0)
Declare @EmpId as Nvarchar (50)
Declare @PaidAmount AS Numeric(18,2)
Declare @DedJamsostek AS Numeric(18,2)

BEGIN	
			
SET XACT_ABORT ON
DECLARE CR_DA CURSOR FOR 

SELECT  -- Checkroll.AdvancePayment.EstateID, 
		-- Checkroll.AdvancePayment.ActiveMonthYearID,
			Checkroll.AdvancePaymentDet.EmpID, 
			SUM(ISNULL(Checkroll.AdvancePaymentDet.Amount,0)),
			-- 19-12-2011 SUM(ISNULL(Checkroll.AdvancePaymentDet.Amount,0))+SUM(ISNULL(C_THR.RoundUp,0)),
			SUM(ISNULL(Checkroll.AdvancePaymentDet.DedJamsostek,0)) 
FROM        Checkroll.AdvancePayment INNER JOIN
            Checkroll.AdvancePaymentDet 
            ON Checkroll.AdvancePayment.AdvancePaymentID = 
            Checkroll.AdvancePaymentDet.AdvancePaymentID
			--08-12-2011
			LEFT JOIN Checkroll.THR AS C_THR ON (C_THR.ActiveMonthYearID = Checkroll.AdvancePayment.ActiveMonthYearID 
									AND C_THR.EmpID = Checkroll.AdvancePaymentDet.EmpID 
									AND C_THR.EstateID = Checkroll.AdvancePayment.EstateID)    
WHERE	     AdvancePayment.EstateID =@EstateId  
AND  AdvancePayment.ActiveMonthYearID =@ActiveMonthYearId
AND ISNULL(Amount,0) > 0  
GROUP BY Checkroll.AdvancePayment.EstateID,Checkroll.AdvancePayment.ActiveMonthYearID,
 Checkroll.AdvancePaymentDet.EmpID

	Open CR_DA

		FETCH NEXT FROM CR_DA
 		INTO @EmpID,@PaidAmount,@DedJamsostek -- @ActiveMonthYearID,@EstateID,@EmpID,@Amount,@DedJamsostek
		
	SELECT  @pTotRow = @@CURSOR_ROWS
		WHILE @@FETCH_STATUS = 0 
		BEGIN
	

		--IF EXISTS(SELECT EmpID from Checkroll.Salary 
		--WHERE EstateID = @EstateId AND ActiveMonthYearID = @ActiveMonthYearId 
		--AND  EmpID = @EmpID)
		--	BEGIN
	
			--UPDATE  Checkroll.Salary 
			--SET 
			--	DedAdvance  =ISNULL(@Amount,0),
			--	DedAstek =ISNULL(@DedJamsostek,0),
			--	ModifiedBy=@User,
			--	ModifiedOn=GETDATE()
			--	WHERE EstateID = @EstateId AND ActiveMonthYearID =@ActiveMonthYearId 
			--	AND  EmpID = @EmpID  
		
		
			UPDATE Checkroll.Salary 
			SET 
			DedAdvance  = ISNULL(@PaidAmount,0),
			DedAstek = 0, 
			ModifiedBy=@User,
			ModifiedOn=GETDATE()
			WHERE EstateID = @EstateId AND ActiveMonthYearID =@ActiveMonthYearId 
			AND  EmpID = @EmpID  
		
		--END
			
		--FETCH NEXT FROM CR_DA
 	--	INTO @ActiveMonthYearID,@EstateID,@EmpID,@Amount,@DedJamsostek
  			FETCH NEXT FROM CR_DA
 		INTO @EmpID,@PaidAmount,@DedJamsostek -- @ActiveMonthYearID,@EstateID,@EmpID,@Amount,@DedJamsostek
 				
		END
		CLOSE CR_DA

DEALLOCATE CR_DA

--=========================================================================================
Declare @RoundUp AS Numeric(18,2)

--DECLARE CR_THR CURSOR FOR 

--SELECT  EmpID, SUM(ISNULL(RoundUp,0))
--FROM        Checkroll.THR
--WHERE	    EstateID =@EstateId  
--AND  ActiveMonthYearID =@ActiveMonthYearId
--AND ISNULL(RoundUp,0) > 0  
--GROUP BY EstateID,ActiveMonthYearID,EmpID

--	Open CR_THR

--		FETCH NEXT FROM CR_THR
-- 		INTO @EmpID,@RoundUp
		
--	SELECT  @pTotRow = @@CURSOR_ROWS
--		WHILE @@FETCH_STATUS = 0 
--		BEGIN

--			UPDATE Checkroll.Salary 
--			SET 
--			DedAdvance  = ISNULL(DedAdvance,0)+ISNULL(@RoundUp,0),
--			ModifiedBy=@User,
--			ModifiedOn=GETDATE()
--			WHERE EstateID = @EstateId AND ActiveMonthYearID =@ActiveMonthYearId 
--			AND  EmpID = @EmpID  

--  			FETCH NEXT FROM CR_THR
-- 		INTO @EmpID,@RoundUp
 				
--		END
--		CLOSE CR_THR

--DEALLOCATE CR_THR

--=========================================================================================

SELECT      Checkroll.AdvancePayment.EstateID, 
		Checkroll.AdvancePayment.ActiveMonthYearID,
			Checkroll.AdvancePaymentDet.EmpID, 
			SUM(ISNULL(Checkroll.AdvancePaymentDet.Amount,0)),
			SUM(ISNULL(Checkroll.AdvancePaymentDet.DedJamsostek,0)) 
FROM        Checkroll.AdvancePayment INNER JOIN
            Checkroll.AdvancePaymentDet 
            ON Checkroll.AdvancePayment.AdvancePaymentID = 
            Checkroll.AdvancePaymentDet.AdvancePaymentID
WHERE	     AdvancePayment.EstateID =@EstateId  
AND  AdvancePayment.ActiveMonthYearID =@ActiveMonthYearId
AND ISNULL(Amount,0) > 0  
GROUP BY Checkroll.AdvancePayment.EstateID,Checkroll.AdvancePayment.ActiveMonthYearID,
 Checkroll.AdvancePaymentDet.EmpID 

END
