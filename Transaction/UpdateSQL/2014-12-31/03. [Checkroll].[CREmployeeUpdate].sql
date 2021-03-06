GO
/****** Object:  StoredProcedure [Checkroll].[CREmployeeUpdate]    Script Date: 31/12/2014 21:13:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









-- ====================================================
-- Created By : Nelson
-- Modified By: SIVA SUBRAMANIAN S
-- Created date: 15 Sep 2009
-- Last Modified Date:22 Jun 2010
-- Module     :CheckRoll,Employee Master, RKPMS Web
-- Screen(s)  : EmployeeMaster.aspx
-- Description: Updating  employee
-- =====================================================
ALTER PROCEDURE [Checkroll].[CREmployeeUpdate]
-- Add the parameters for the stored procedure here
@EmpID nvarchar(50)output,
        @EstateID nvarchar(50),
        @Category nvarchar(50) ,
        @EmpCode nvarchar(50),
        @EmpName nvarchar(80),
        @EmpImage image ,
        @HomeAdd1 nvarchar(80),
        @FamilyName nvarchar(80),
        @FamilyCardNo nvarchar(80),
        @Insurance nvarchar(80),
        @HomeTelMobileNo nvarchar(50),
        @EthnicGroup nvarchar(50),
        @WorkerType nvarchar(50),
        @BankID nvarchar(50),
        @AccountNo nvarchar(50),
        @Position nvarchar(50),
        @StationID nvarchar(50) ,
        @Gender CHAR(1) ,
        @DOB    DATETIME,
        @KTP nvarchar(50) ,
        @PassportNo nvarchar(50) ,
        @JamsostekNo nvarchar(50) ,
        @NPWP nvarchar(50),
        @Religion nvarchar(50),
        @MaritalStatus CHAR(3),
        @NoOfChildrenforTax nvarchar(50) ,
        @Mandor  CHAR(1),
        @Krani   CHAR(1),
        @RestDay CHAR(3),
        @DOJ     DATETIME ,
        @Status nvarchar(15),
        @StatusDate DATETIME ,
        @TransferLocation nvarchar(50),
        @WifeEmpWithREA            CHAR(1),
        @WifeNotStayinREA          CHAR(1),
        @WifeStayinREAreceivesRice CHAR(1),
        @FatherName nvarchar(80),
        @FDobAndPlace nvarchar(100),
        @FAddress nvarchar(200),
        @FTribe nvarchar(80),
        @FReligion nvarchar(80),
        @MotherName nvarchar(80),
        @MDobAndPlace nchar(10),
        @MAddress nvarchar(200),
        @MTribe nvarchar(80),
        @MReligion nvarchar(80),
        @HusbWifeName nvarchar(80),
        @HWDOBAndPlace nvarchar(100),
        @HWAddress nvarchar(200),
        @HWIDNo nvarchar(80),
        @HWMarriageCertNo nvarchar(80),
        @HWFamilyCardNo nvarchar(80),
        @HWEthnicGroup nvarchar(80),
        @HWReligion nvarchar(80),
        @Elementry nvarchar(100),
        @Junior nvarchar(100) ,
        @Senior nvarchar(100) ,
        @Diploma nvarchar(100) ,
        @Degree nvarchar(100),
        --@ConcurrencyId rowversion output,
        @ModifiedBy nvarchar(50),
        @ModifiedOn DATETIME,
        @MedClaimAllowanceLimit numeric(18,0),
        @HaveNPWP nvarchar(100),
		@JobDescription int,
		@Grade nvarchar(100),
		@Level nvarchar(100)
AS
        BEGIN TRY
                IF EXISTS
                ( SELECT *
                FROM    Checkroll.CREmployee
                WHERE   EstateID=@EstateID
                    AND
                        (
                                EmpCode = @EmpCode
                        )
                    AND EmpID <> @EmpID
                )
                BEGIN
                        SELECT 0
                END
                ELSE
                BEGIN
                        UPDATE [Checkroll].[CREmployee]
                        SET --EmpID=@EmpID,
                               --EstateID=@EstateID,
                               Category                 =@Category                 ,
                               EmpCode                  =@EmpCode                  ,
                               EmpName                  =@EmpName                  ,
                               EmpImage                 =@EmpImage                 ,
                               HomeAdd1                 = @HomeAdd1                ,
                               FamilyName               = @FamilyName              ,
                               FamilyCardNo             = @FamilyCardNo            ,
                               Insurance                = @Insurance               ,
                               HomeTelMobileNo          = @HomeTelMobileNo         ,
                               EthnicGroup              =@EthnicGroup              ,
                               WorkerType               =@WorkerType               ,
                               BankID                   =@BankID                   ,
                               AccountNo                =@AccountNo                ,
                               Position                 =@Position                 ,
                               StationID                =@StationID                ,
                               Gender                   =@Gender                   ,
                               DOB                      =@DOB                      ,
                               KTP                      =@KTP                      ,
                               PassportNo               =@PassportNo               ,
                               JamsostekNo              =@JamsostekNo              ,
                               NPWP                     =@NPWP                     ,
                               Religion                 =@Religion                 ,
							   Grade                 =@Grade                 ,
							   Level                 =@Level                 ,
                               MaritalStatus            =@MaritalStatus            ,
                               NoOfChildrenforTax       =@NoOfChildrenforTax       ,
                               Mandor                   =@Mandor                   ,
                               Krani                    =@Krani                    ,
                               RestDay                  =@RestDay                  ,
                               DOJ                      =@DOJ                      ,
                               Status                   =@Status                   ,
                               StatusDate               = @StatusDate              ,
                               TransferLocation         =@TransferLocation         ,
                               WifeEmpWithREA           =@WifeEmpWithREA           ,
                               WifeNotStayinREA         =@WifeNotStayinREA         ,
                               WifeStayinREAreceivesRice=@WifeStayinREAreceivesRice,
                               FatherName               =@FatherName               ,
                               FDobAndPlace             =@FDobAndPlace             ,
                               FAddress                 =@FAddress                 ,
                               FTribe                   = @FTribe                  ,
                               FReligion                = @FReligion               ,
                               MotherName               =@MotherName               ,
                               MDobAndPlace             =@MDobAndPlace             ,
                               MAddress                 =@MAddress                 ,
                               MTribe                   = @MTribe                  ,
                               MReligion                = @MReligion               ,
                               HusbWifeName             =@HusbWifeName             ,
                               HWDOBAndPlace            =@HWDOBAndPlace            ,
                               HWAddress                =@HWAddress                ,
                               HWIDNo                   = @HWIDNo                  ,
                               HWMarriageCertNo         = @HWMarriageCertNo        ,
                               HWFamilyCardNo           = @HWFamilyCardNo          ,
                               HWEthnicGroup            = @HWEthnicGroup           ,
                               HWReligion               = @HWReligion              ,
                               Elementry                =@Elementry                ,
                               Junior                   =@Junior                   ,
                               Senior                   =@Senior                   ,
                               Diploma                  =@Diploma                  ,
                               Degree                   =@Degree                   ,
                               ModifiedBy               =@ModifiedBy               ,
                               ModifiedOn               =@ModifiedOn			   ,
                               MedClaimAllowanceLimit	=@MedClaimAllowanceLimit   ,
                               HaveNPWP					=@HaveNPWP,
							   EmpJobDescriptionId = @JobDescription
                        WHERE  EmpID                    =@EmpID
                           AND EstateID                 =@EstateID ;
                        
                        SELECT 1
                        --SELECT @ConcurrencyId = ConcurrencyId FROM Checkroll .CREmployee
                        --WHERE EmpID=@EmpID;
                END
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










