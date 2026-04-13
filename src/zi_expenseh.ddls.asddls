@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Expense Header Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #M,
  dataClass: #TRANSACTIONAL
}
define root view entity ZI_ExpenseH
  as select from zexp_h
  composition [0..*] of ZI_ExpenseI as _Items
  association [0..1] to ZI_StoreVH   as _Store
    on $projection.StoreId = _Store.StoreId
  association [0..1] to ZI_VendorVH  as _Vendor
    on $projection.VendorId = _Vendor.VendorId
  association [0..1] to ZI_ExpCatVH  as _ExpCat
    on $projection.ExpCat = _ExpCat.ExpCatId
  association [0..1] to ZI_PayModeVH as _PayMode
    on $projection.PayMode = _PayMode.PayModeId
{
  key exp_uuid              as ExpUuid,
      exp_id                as ExpId,
      store_id              as StoreId,
      city                  as City,
      region                as Region,
      cost_center           as CostCenter,
      vendor_id             as VendorId,
      exp_cat               as ExpCat,
      pay_mode              as PayMode,
      gst_slab              as GstSlab,

      @Semantics.amount.currencyCode: 'Currency'
      total_amt             as TotalAmt,

      @Semantics.amount.currencyCode: 'Currency'
      base_amt              as BaseAmt,

      @Semantics.amount.currencyCode: 'Currency'
      cgst_amt              as CgstAmt,

      @Semantics.amount.currencyCode: 'Currency'
      sgst_amt              as SgstAmt,

      currency              as Currency,
      status                as Status,
      created_by            as CreatedBy,
      created_on            as CreatedOn,
      local_last_changed_at as LocalLastChangedAt,

      /* Associations */
      _Items,
      _Store,
      _Vendor,
      _ExpCat,
      _PayMode
}
