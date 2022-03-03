class ApiService { 
    
    [Hashtable]$apiCallParams = @{}

    ApiService([hashtable] $params) 
    {
        if ($null -eq $params.uri) {
            throw("❌ uri cannot be null")
        }
        $this.apiCallParams = $params       
    }

    [object] Invoke() {
        try {
            $p = $this.apiCallParams        
            return Invoke-RestMethod @p
        }
        catch {
            Write-Host "Error in ApiService.Invoke(): $Error"
            return "Error x: $Error"
        }
    }
}