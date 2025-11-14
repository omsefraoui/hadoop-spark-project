# Script de build optimisé pour Windows
# Auteur: Omar Sefraoui - ENSAO

Write-Host "🚀 Build Hadoop-Spark-Cluster" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Activer BuildKit
$env:DOCKER_BUILDKIT = 1
Write-Host "✓ BuildKit activé" -ForegroundColor Green

# Nom de l'image
$IMAGE_NAME = "omsefraoui/hadoop-spark-cluster"
$IMAGE_TAG = "latest"

Write-Host "📦 Construction de l'image: $IMAGE_NAME:$IMAGE_TAG" -ForegroundColor Yellow
Write-Host ""

# Build avec mesure du temps
$StartTime = Get-Date

try {
    docker build `
        --cache-from "$IMAGE_NAME:$IMAGE_TAG" `
        -t "$IMAGE_NAME:$IMAGE_TAG" `
        -t "$IMAGE_NAME:dev" `
        .
    
    if ($LASTEXITCODE -eq 0) {
        $EndTime = Get-Date
        $Duration = ($EndTime - $StartTime).TotalSeconds
        
        Write-Host ""
        Write-Host "✅ Build réussi en $([math]::Round($Duration, 2)) secondes!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📊 Informations de l'image:" -ForegroundColor Cyan
        docker images $IMAGE_NAME --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
        
        Write-Host ""
        Write-Host "🎯 Prochaines étapes:" -ForegroundColor Yellow
        Write-Host "  1. Tester l'image:" -ForegroundColor White
        Write-Host "     docker run -it --rm $IMAGE_NAME:$IMAGE_TAG" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  2. Lancer avec tous les ports:" -ForegroundColor White
        Write-Host "     docker-compose up -d" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  3. Publier sur DockerHub:" -ForegroundColor White
        Write-Host "     docker push $IMAGE_NAME:$IMAGE_TAG" -ForegroundColor Gray
        Write-Host ""
        
    } else {
        throw "Le build Docker a échoué"
    }
}
catch {
    Write-Host ""
    Write-Host "❌ Erreur lors du build: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Conseils de dépannage:" -ForegroundColor Yellow
    Write-Host "  - Vérifiez que Docker Desktop est démarré" -ForegroundColor White
    Write-Host "  - Assurez-vous d'avoir assez d'espace disque" -ForegroundColor White
