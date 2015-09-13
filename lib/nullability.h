// Xcode 6.3 defines new language features to declare nullability
#if __has_feature(nullability)
#define PSPDF_ASSUME_NONNULL_BEGIN _Pragma("clang assume_nonnull begin")
#define PSPDF_ASSUME_NONNULL_END _Pragma("clang assume_nonnull end")
#define ps_nullable nullable
#define ps_nonnull nonnull
#define ps_null_unspecified null_unspecified
#define ps_null_resettable null_resettable
#define __ps_nullable __nullable
#define __ps_nonnull __nonnull
#define __ps_null_unspecified __null_unspecified
#else
#define PSPDF_ASSUME_NONNULL_BEGIN
#define PSPDF_ASSUME_NONNULL_END
#define ps_nullable
#define ps_nonnull
#define ps_null_unspecified
#define ps_null_resettable
#define __ps_nullable
#define __ps_nonnull
#define __ps_null_unspecified
#endif