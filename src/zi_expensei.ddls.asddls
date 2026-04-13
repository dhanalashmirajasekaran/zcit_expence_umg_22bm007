@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Expense Line Items Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #M,
  dataClass: #TRANSACTIONAL
}
define view entity ZI_ExpenseI
  as select from zexp_i
  association to parent ZI_ExpenseH as _Header
    on $projection.ExpUuid = _Header.ExpUuid
{
  key exp_uuid              as ExpUuid,
  key item_uuid             as ItemUuid,
      item_no               as ItemNo,
      item_desc             as ItemDesc,
      quantity              as Quantity,
      unit                  as Unit,

      @Semantics.amount.currencyCode: 'Currency'
      unit_price            as UnitPrice,

      @Semantics.amount.currencyCode: 'Currency'
      item_amt              as ItemAmt,

      @Semantics.amount.currencyCode: 'Currency'
      item_gst_amt          as ItemGstAmt,

      @Semantics.amount.currencyCode: 'Currency'
      item_total_amt        as ItemTotalAmt,

      currency              as Currency,
      receipt_filename      as ReceiptFilename,
      receipt_mimetype      as ReceiptMimetype,
      receipt_content       as ReceiptContent,
      local_last_changed_at as LocalLastChangedAt,

      _Header
}
