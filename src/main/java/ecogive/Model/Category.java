package ecogive.Model;

import java.math.BigDecimal;

public class Category {
    private int categoryId;
    private String name;
    private BigDecimal fixedPoints;

    public Category() {
    }

    public Category(int categoryId, String name, BigDecimal fixedPoints) {
        this.categoryId = categoryId;
        this.name = name;
        this.fixedPoints = fixedPoints;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public BigDecimal getFixedPoints() {
        return fixedPoints;
    }

    public void setFixedPoints(BigDecimal fixedPoints) {
        this.fixedPoints = fixedPoints;
    }
}
