///---integration
func jsonToUuid(_ jsonInfo: String) -> [String: String] {
    return["beatbox": "973A007E-3C38-45C6-B2DD-0141DD82F973", "SW1": "1D04E43A-4B06-41D9-A499-7594D94A7814", "SL1": "1D24E43A-4B06-41D9-A499-7594D94A7814", "LA1": "1D14E43A-4B06-41D9-A499-7594D94A7814"]
}

func uuidToJson(service: String, characteristics: [String]? = nil) -> String? {
    if let _ = characteristics {
       return(" {\"name\":\"beatbox\",\"chars\":[{\"label\":\"Power\",\"x\":\"20\",\"type\":\"switch\",\"name\":\"SW1\",\"y\":\"100\"},{\"label\":\"Volume\",\"x\":\"20\",\"type\":\"slider\",\"name\":\"SL1\",\"y\":\"200\"},{\"label\":\"BPM\",\"x\":\"20\",\"type\":\"output\",\"name\":\"LA1\",\"y\":\"300\"}]}")
    } else if service ==  "973A007E-3C38-45C6-B2DD-0141DD82F973" {
        return("{\"name\":\"beatbox\"}")
    } else {
        return nil
    }
}

