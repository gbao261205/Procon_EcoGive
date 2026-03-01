package ecogive.Model;

import java.math.BigDecimal;

public enum Tier {
    STANDARD(BigDecimal.valueOf(1.0), BigDecimal.ZERO),
    SILVER(BigDecimal.valueOf(1.05), BigDecimal.valueOf(0.05)),
    GOLD(BigDecimal.valueOf(1.1), BigDecimal.valueOf(0.10)),
    DIAMOND(BigDecimal.valueOf(1.2), BigDecimal.valueOf(0.20));

    private final BigDecimal bonusMultiplier;
    private final BigDecimal discountRate;

    Tier(BigDecimal bonusMultiplier, BigDecimal discountRate) {
        this.bonusMultiplier = bonusMultiplier;
        this.discountRate = discountRate;
    }

    public BigDecimal getBonusMultiplier() {
        return bonusMultiplier;
    }

    public BigDecimal getDiscountRate() {
        return discountRate;
    }
}
