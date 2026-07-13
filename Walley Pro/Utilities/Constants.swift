import Foundation

struct Constants {
    static let defaultDropboxToken = "sl.u.AGlIM4wuCGeTNilfAvPLt8_P8E25d-7izgujuGUfhIV2rsWoXiSmWqElervX9kIPY9HtlB1osFxAzxTplQROzSkwi2MhujPM9znwwFqX8ch5-7OkFjiYzBiET-sFQIIQaHhjXpNULdTmIfqwY2-_bxvINjFpmAzLO1Hkhgr61o8UcGaqV7rc-v8UVAsgWa-Y3p7ldKhuUEy5DGS_d_2ux8qWNAm64vrrO-_e-UrxP_eF29kE3xatoFN-rV6ncJFhXtUE9gcxuHzRl2_TRmDfjJT3Lqg4QAnFQsL5TvrXrbamNlWWMDxR3NRZC3WxZRyIHI5y5QArI6ZU9bSQQFHLOfVI1ZAengL_1Q6yTLFEWEPNOzX9Lwg7hQ_FRVpcWNDimbPSUki4kj96hcv1k_Vbhpqd6PMKLa7keRoTpGezWGe9APP0Q37veZFyLV8tio3Fyi0z3-ad9XAuStCUxQQxAWwreaTJwGvyrueAE6U1Bg57RlHMB_gh82sNbBRX17jDMs2A4Ed9ZRFE8-nVTQo9bKXkKqHZ3DOpB0_HVWr05Cc5U_oRqOKc0fgu2Y5k3-HoKG8idEdSIxFZtPHUz75bdZj5oK6a93bg4_pOSYIsMAZXdv3sLETVgi5p2CMQwbmPLKjOiorJddipK5sPs3C1Y6oNp-LCdjZSmPfxKrcCkGeJd0wbLhS2Dj-o9agsHVgzacIgd48Mo42tAAm5mpJbEfUD1a0y_UvAtPomU9CoNiNDdEPAsoYmQQgHX7RXBNpXNGko46y8OoMuW44EEwGLQyDMp9Ioo97q_alJFzD2Y_VCCr_5iFWN75p6G9ISTmbrVPNcdle-6RtxTwLtZDmGHdF2ZwWPqufsrNJvMNK4LuhVe_uq6ik9MJ8kKnCRQ5-h7IQGTO_1lcL9UTzfgfjOxJhMWAnplw5kr96jSIw7U3F2fxo0eZO6R_AuY--npyxnS-yRP1D9bZNJ1zGRs3szFv72emXadcfYGltyGpcYfXiM-nMePiyvBRqlUnl-De97n1gqifOd_qQTNm4A7ZRCPhjGed2V7S4_zXyEipPg3qwmed2k0TV95r_qGFdKhwjMpTphW0DlHdIa1nZfJbXTrKOdOwaz1yjWzul-NIDA87U_TLr49VDD0OGt6CkxnQxnSMevkyzT0c-r60eZC88-IfNFfhmOaWvZ63TQ43yaHoOMqL1HAKIVD03n2KmJ0O_1mKuK3V0eSWf6_VQPnNxNKE6VypiKusQoBm2KCiHeXzrtSwT08M4SrUKZhmZaNuFMsuD7mEUCmpTnHZDgR6yo6OBY5HUxdv3h7DBMS-W1V73-lQ"
    static let defaultDropboxRootPath = "/Wallpapers"
    static let apiBaseURL = "https://api.dropboxapi.com/2"
    static let imageExtensions = ["jpg", "jpeg", "png", "heic", "webp", "gif"]

    static var dropboxToken: String {
        let token = UserDefaults.standard.string(forKey: "dropboxToken") ?? defaultDropboxToken
        return token.isEmpty ? defaultDropboxToken : token
    }

    static var dropboxRootPath: String {
        let path = UserDefaults.standard.string(forKey: "dropboxRootPath") ?? defaultDropboxRootPath
        return path.isEmpty ? defaultDropboxRootPath : path
    }
}
